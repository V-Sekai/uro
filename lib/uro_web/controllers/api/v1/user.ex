defmodule UroWeb.API.V1.UserController do
  @moduledoc false

  use UroWeb, :controller
  use UroWeb.Helpers.API
  use OpenApiSpex.ControllerSpecs

  import UroWeb.Helpers.User

  alias OpenApiSpex.Schema
  alias Uro.Accounts
  alias Uro.Accounts.User
  alias Uro.Plug.Authentication
  alias Uro.Repo
  alias UroWeb.API.V1.SessionController.SchemaSession
  alias UroWeb.Helpers.API.SchemaError

  action_fallback(UroWeb.FallbackController)

  tags(["users"])
  security(default_security())

  operation(:show,
    operation_id: "getUser",
    summary: "Get a specific user.",
    parameters: [
      id: [
        in: :path,
        schema: User.IDSchema
      ]
    ],
    responses: [
      ok: {
        "",
        "application/json",
        User.Schema
      },
      not_found: {
        "User not found",
        "application/json",
        SchemaError
      }
    ]
  )

  def show(conn, %{"id" => id}) do
    conn
    |> resolve_user_from_id(id)
    |> case do
      %Accounts.User{} = user ->
        conn
        |> put_status(200)
        |> json(user)

      _ ->
        json_error(conn, "User not found", status: 404)
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
           :password
         ],
         properties: %{
           display_name: %Schema{type: :string},
           username: %Schema{type: :string},
           email: %Schema{type: :string},
           password: %Schema{type: :string}
         }
       }},
    responses: [
      ok: {
        "",
        "application/json",
        SchemaSession
      },
      unprocessable_entity: {
        "",
        "application/json",
        SchemaError
      }
    ]
  )

  def create(conn, params) do
    Repo.transaction(fn ->
      with {:ok, user, conn} <- Uro.Accounts.create_user(conn, params),
           :ok <- Uro.Accounts.send_confirmation_email(user),
           conn <- Pow.Plug.create(conn, user) do
        {user, conn}
      else
        reason ->
          Repo.rollback(reason)
      end
    end)
    |> case do
      {:ok, {_, conn}} ->
        session =
          conn
          |> Authentication.current_session()
          |> Authentication.transform_session()

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
        schema: User.IDSchema
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
    resolve_user_from_id(conn, user_id)
    |> case do
      %User{} = user ->
        :ok = Uro.Accounts.send_confirmation_email(user)

        conn
        |> put_status(:accepted)
        |> json(%{})

      _ ->
        json_error(conn, "User not found", status: 404)
    end
  end

  operation(:update_email,
    operation_id: "updateEmail",
    summary: "Update a user's email address.",
    parameters: [
      user_id: [
        in: :path,
        schema: User.IDSchema
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
        User.Schema
      }
    ]
  )

  def update_email(conn, %{
        "user_id" => user_id,
        "email" => email,
        "send_confirmation" => send_confirmation
      }) do
    %{id: current_user_id, user_privilege_ruleset: %{is_admin: is_admin}} =
      Authentication.current_user(conn) |> IO.inspect()

    if not is_admin do
      send_confirmation = false
    end

    resolve_user_from_id(conn, user_id)
    |> case do
      nil ->
        json_error(conn, "User not found", status: 404)

      %User{id: ^current_user_id} = user ->
        with {:ok, user} <-
               Uro.Accounts.update_email(user, email, send_confirmation: send_confirmation) do
          conn
          |> put_status(:ok)
          |> json(user)
        end
    end
  end

  def update_email(conn, %{"user_id" => user_id, "email" => email}),
    do: update_email(conn, %{"user_id" => user_id, "email" => email, "send_confirmation" => true})

  operation(:confirm_email,
    operation_id: "confirmEmail",
    summary: "Confirm a user's email address.",
    parameters: [
      user_id: [
        in: :path,
        schema: User.IDSchema
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
        User.Schema
      }
    ]
  )

  def confirm_email(conn, %{"user_id" => user_id, "token" => token}) do
    resolve_user_from_id(conn, user_id)
    |> case do
      %User{} = user ->
        Uro.Accounts.confirm_email(user, token)
        |> case do
          {:ok, user} ->
            json(conn, user)

          {:error, _} ->
            json_error(conn, "Invalid confirmation token", status: 422)
        end

      _ ->
        json_error(conn, "User not found", status: 404)
    end
  end
end
