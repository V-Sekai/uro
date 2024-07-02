defmodule Uro.UserController do
  @moduledoc false

  alias Uro.Turnstile
  use Uro, :controller
  use Uro.Helpers.API
  use OpenApiSpex.ControllerSpecs

  import Ecto.Changeset
  import Uro.Helpers.User
  import Uro.Helpers.Changeset

  alias OpenApiSpex.Schema
  alias Uro.Accounts
  alias Uro.Accounts.User
  alias Uro.Error
  alias Uro.Plug.Authentication
  alias Uro.Repo
  alias Uro.Session

  action_fallback(Uro.FallbackController)
  # plug(Uro.Plug.CastAndValidate, render_error: FallbackController)

  tags(["users"])
  security(default_security())

  def user_not_found(conn), do: json_error(conn, code: :not_found, message: "User not found")

  operation(:show,
    operation_id: "getUser",
    summary: "Get a specific user.",
    parameters: [
      id: [
        in: :path,
        schema: User.LooseKey
      ]
    ],
    responses: [
      ok: {
        "",
        "application/json",
        User.JSONSchema
      },
      not_found: {
        "User not found",
        "application/json",
        Error.JSONSchema
      }
    ]
  )

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- user_from_key(conn, id) do
      conn
      |> put_status(200)
      |> json(user)
    end
  end

  operation(:create,
    operation_id: "signup",
    summary: "Create a new user.",
    request_body:
      {"", "application/json",
       %Schema{
         type: :object,
         required: [
           :display_name,
           :username,
           :email,
           :password,
           :captcha
         ],
         properties: %{
           display_name: User.JSONSchema.shape(:display_name),
           username: User.JSONSchema.shape(:username),
           email: User.JSONSchema.shape(:email),
           password: %Schema{type: :string},
           captcha: %Schema{
             type: :string
           }
         }
       }},
    responses: [
      ok: {
        "",
        "application/json",
        Session.JSONSchema
      },
      unprocessable_entity: {
        "",
        "application/json",
        Error.JSONSchema
      }
    ]
  )

  def create(conn, params) do
    Repo.transaction(fn ->
      with {:ok, _} <- Turnstile.verify_captcha(conn),
           {:ok, user, conn} <- Accounts.create_user(conn, params),
           :ok <- Accounts.send_confirmation_email(user),
           conn <- Pow.Plug.create(conn, user) do
        {user, conn}
      else
        reason ->
          Repo.rollback(reason)
      end
    end)
    |> case do
      {:ok, {_, conn}} ->
        session = Uro.Plug.Authentication.current_session(conn)

        json(
          conn,
          session
        )

      {:error, conn} ->
        conn
    end
  end

  operation(:resend_confirmation_email,
    operation_id: "resendConfirmationEmail",
    summary: "Resend a confirmation email.",
    parameters: [
      user_id: [
        in: :path,
        schema: User.LooseKey
      ]
    ],
    responses: [
      accepted: {
        "",
        "application/json",
        %Schema{type: :object}
      }
    ]
  )

  def resend_confirmation_email(conn, %{"user_id" => user_id}) do
    with {:ok, current_user} <- current_user(conn),
         {:ok, user} <- user_from_key(conn, user_id),
         true <-
           User.admin?(current_user) or user.id == current_user.id ||
             {
               :error,
               :unauthorized,
               "You do not have permission to resend this user's confirmation email"
             },
         :ok <- Accounts.send_confirmation_email(user) do
      conn
      |> put_status(:accepted)
      |> json(%{})
    end
  end

  operation(:update_email,
    operation_id: "updateEmail",
    summary: "Update a user's email address.",
    parameters: [
      user_id: [
        in: :path,
        schema: User.LooseKey
      ]
    ],
    request_body:
      {"", "application/json",
       %Schema{
         type: :object,
         required: [
           :email
         ],
         properties: %{
           email: %Schema{
             type: :string,
             format: "email",
             description: "The new email address."
           },
           current_password: %Schema{
             type: :string,
             description: "The user's current password."
           },
           send_confirmation: %Schema{
             type: :boolean,
             default: true,
             description: "Whether to send a confirmation email."
           }
         }
       }},
    responses: [
      ok: {
        "",
        "application/json",
        User.JSONSchema
      }
    ]
  )

  def update_email(conn, %{"user_id" => user_id} = params) do
    with {:ok, current_user} <- current_user(conn),
         {:ok, user} <- user_from_key(conn, user_id),
         {:ok,
          %{
            email: email,
            send_confirmation: send_confirmation
          }} <-
           cast(
             {%{},
              %{
                user_id: :string,
                email: :string,
                current_password: :string,
                send_confirmation: :boolean
              }},
             Map.merge(params, %{
               "user_id" => user.id,
               "password_hash" => user.password_hash
             }),
             [
               :user_id,
               :email,
               :current_password,
               :send_confirmation
             ]
           )
           |> validate_required([:email])
           |> put_default(:send_confirmation, true)
           |> then(fn changeset ->
             if User.admin?(current_user) do
               changeset
             else
               changeset
               |> validate_as_yourself(current_user)
               |> validate_inclusion(:send_confirmation, [true], message: "must be true")
               |> User.validate_current_password(user)
             end
           end)
           |> apply_action(nil),
         {:ok, user} <- Accounts.update_email(user, email, send_confirmation: send_confirmation) do
      json(conn, user)
    end
  end

  operation(:confirm_email,
    operation_id: "confirmEmail",
    summary: "Confirm a user's email address.",
    parameters: [
      user_id: [
        in: :path,
        schema: User.LooseKey
      ]
    ],
    request_body:
      {"", "application/json",
       %Schema{
         type: :object,
         required: [
           :token
         ],
         properties: %{
           token: %Schema{
             type: :string,
             description: "The confirmation token."
           }
         }
       }},
    responses: [
      ok: {
        "",
        "application/json",
        User.JSONSchema
      }
    ]
  )

  def confirm_email(conn, %{"user_id" => user_id, "token" => token}) do
    with {:ok, user} <- user_from_key(conn, user_id),
         {:ok, user} <- Accounts.confirm_email(user, token) do
      json(conn, user)
    end
  end

  def confirm_email(_, _), do: {:error, :bad_request}

  operation(:update,
    operation_id: "updateUser",
    summary: "Update a user.",
    parameters: [
      user_id: [
        in: :path,
        schema: User.LooseKey
      ]
    ],
    request_body: {"", "application/json", User.UpdateJSONSchema},
    responses: [
      ok: {
        "",
        "application/json",
        User.JSONSchema
      }
    ]
  )

  def update(
        conn,
        %{
          "user_id" => user_id
        } = params
      ) do
    with {:ok, current_user} <-
           Authentication.current_user(conn)
           |> user_confirmed_email(),
         {:ok, user} <- user_from_key(conn, user_id),
         true <-
           User.admin?(current_user) or user.id == current_user.id ||
             {
               :error,
               :unauthorized,
               "You do not have permission to update this user"
             },
         {:ok, user} <- Accounts.update_user(user, params) do
      conn
      |> put_status(:ok)
      |> json(user)
    end
  end
end
