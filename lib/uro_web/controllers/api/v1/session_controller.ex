defmodule UroWeb.API.V1.SessionController do
  use UroWeb, :controller
  use UroWeb.Helpers.Auth
  alias UroWeb.APIAuthPlug
  alias Plug.Conn

  @doc false
  defp login_valid(conn) do
    conn
    |> json(%{data: %{access_token: conn.private[:api_access_token], renewal_token: conn.private[:api_renewal_token]}})
  end

  @doc false
  defp login_invalid(conn) do
    conn
    |> put_status(401)
    |> json(%{error: %{status: 401, message: "Invalid email or password"}})
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> validate_login(user_params)
    |> case do
      {:ok, conn} -> login_valid(conn)
      {:error, conn} -> login_invalid(conn)
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

      {conn, _user} ->
        json(conn, %{data: %{access_token: conn.private[:api_access_token], renewal_token: conn.private[:api_renewal_token]}})
    end
  end

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end
end
