defmodule UroWeb.API.V1.SessionController do
  use UroWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use UroWeb.Helpers.API

  alias OpenApiSpex.Schema
  alias Plug.Conn
  alias Uro.Plug.Authentication
  alias UroWeb.Helpers.API.SchemaError

  tags(["session"])
  security(default_security())

  defp invalid_credentials(conn),
    do: json_error(conn, "Invalid email, username or password.", status: 401)

  defp email_unconfirmed(conn) do
    conn
    |> Pow.Plug.delete()
    |> json_error("Your e-mail address has not been confirmed.", status: 401)
  end

  defmodule SchemaSession do
    @moduledoc false

    require OpenApiSpex

    alias OpenApiSpex.Schema
    alias Uro.Accounts.User

    OpenApiSpex.schema(%{
      type: :object,
      title: "Session",
      required: [:user, :access_token, :token_type, :expires_in],
      properties: %{
        user: User.Schema,
        access_token: %Schema{
          type: :string
        },
        token_type: %Schema{
          type: :string,
          example: "Bearer"
        },
        expires_in: %Schema{
          type: :integer
        }
      }
    })
  end

  operation(:show,
    operation_id: "session",
    summary: "Current Session",
    description: "Get the current session.",
    responses: [
      ok: {
        "",
        "application/json",
        SchemaSession
      },
      unauthorized: {
        "Invalid credentials",
        "application/json",
        SchemaError
      }
    ]
  )

  def show(conn, _),
    do:
      json(
        conn,
        Authentication.current_session(conn)
        |> Authentication.transform_session()
      )

  def validate_credentials(conn, %{
        "username" => username,
        "password" => password
      }) do
    Uro.Accounts.get_by_username(username)
    |> case do
      user when not is_nil(user) ->
        Pow.Plug.authenticate_user(conn, %{
          "email" => user.email,
          "password" => password
        })

      _ ->
        {:error, conn}
    end
  end

  def validate_credentials(conn, %{
        "username_or_email" => username_or_email,
        "password" => password
      }) do
    Uro.Accounts.get_by_username_or_email(username_or_email)
    |> case do
      user when not is_nil(user) ->
        Pow.Plug.authenticate_user(conn, %{
          "email" => user.email,
          "password" => password
        })

      _ ->
        {:error, conn}
    end
  end

  def validate_credentials(conn, %{
        "email" => email,
        "password" => password
      }) do
    Pow.Plug.authenticate_user(conn, %{
      "email" => email,
      "password" => password
    })
  end

  def validate_credentials(conn, _), do: {:error, conn}

  defmodule SchemaLoginCredentials do
    @moduledoc false

    require OpenApiSpex
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "LoginCredentials",
      oneOf: [
        %Schema{
          type: :object,
          required: [:username, :password],
          properties: %{
            username: %Schema{type: :string},
            password: %Schema{type: :string}
          }
        },
        %Schema{
          type: :object,
          required: [:email, :password],
          properties: %{
            email: %Schema{type: :string},
            password: %Schema{type: :string}
          }
        },
        %Schema{
          type: :object,
          required: [:username_or_email, :password],
          properties: %{
            username_or_email: %Schema{type: :string},
            password: %Schema{type: :string}
          }
        }
      ]
    })
  end

  operation(:create,
    operation_id: "login",
    summary: "Login",
    description: "Create a new session.",
    request_body: {
      "",
      "application/json",
      SchemaLoginCredentials
    },
    responses: [
      ok: {
        "",
        "application/json",
        SchemaSession
      },
      unauthorized: {
        "Invalid credentials",
        "application/json",
        SchemaError
      }
    ]
  )

  def create(conn, credentials) do
    conn
    |> validate_credentials(credentials)
    |> case do
      {:ok, conn} ->
        conn
        |> Uro.EnsureUserNotLockedPlug.call(UroWeb.APIAuthErrorHandler)
        |> UroWeb.Helpers.Auth.verify_confirmed_or_send_confirmation_email()
        |> case do
          {:ok, conn} -> show(conn, nil)
          {:failed, conn} -> email_unconfirmed(conn)
        end

      {:error, conn} ->
        invalid_credentials(conn)
    end
  end

  operation(:delete,
    operation_id: "logout",
    summary: "Logout",
    description: "Delete the current session.",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{type: :null}
      }
    ]
  )

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _) do
    conn
    |> Pow.Plug.delete()
    |> json(nil)
  end
end
