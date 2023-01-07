defmodule UroWeb.API.V1.SessionController do
  use UroWeb, :controller
  use UroWeb.Helpers.Auth
  alias UroWeb.APIAuthPlug
  alias Plug.Conn

  @doc false
  defp session_data(conn, user) do
    conn
    |> json(%{
      data: %{
        access_token: conn.private[:api_access_token],
        renewal_token: conn.private[:api_renewal_token],
        user: user,
        user_privilege_ruleset: UroWeb.Helpers.Auth.get_user_privilege_ruleset(user)
      }
    })
  end

  @doc false
  defp login_valid(conn) do
    conn
    |> session_data(conn.assigns[:current_user])
  end

  @doc false
  defp login_invalid(conn) do
    conn
    |> put_status(401)
    |> json(%{error: %{status: 401, message: "Invalid email or password"}})
  end

  @doc false
  defp email_unconfirmed(conn) do
    conn
    |> Pow.Plug.delete()
    |> put_status(401)
    |> json(%{error: %{status: 401, message: "Your e-mail address has not been confirmed"}})
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> validate_login(user_params)
    |> case do
      {:ok, conn} ->
        conn
        |> Uro.EnsureUserNotLockedPlug.call(UroWeb.APIAuthErrorHandler)
        |> UroWeb.Helpers.Auth.verify_confirmed_or_send_confirmation_email()
        |> case do
          {:ok, conn} -> login_valid(conn)
          {:failed, conn} -> email_unconfirmed(conn)
        end

      {:error, conn} ->
        login_invalid(conn)
    end
  end

  @spec renew(Conn.t(), map()) :: Conn.t()
  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> APIAuthPlug.renew(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, user} ->
        session_data(conn, user)
    end
  end

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end
end
