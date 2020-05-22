defmodule UroWeb.API.V1.SessionController do
  use UroWeb, :controller

  alias UroWeb.APIAuthPlug
  alias Plug.Conn

  def invalid_login(conn) do
    conn
    |> put_status(401)
    |> json(%{error: %{status: 401, message: "Invalid email or password"}})
  end

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    user = Uro.Accounts.get_by_username_or_email(user_params["username_or_email"] |> String.downcase)

    if user do
      final_params = %{"email" => user.email, "password" => user_params["password"]}

      conn
      |> Pow.Plug.authenticate_user(final_params)
      |> case do
        {:ok, conn} ->
          json(conn, %{data: %{access_token: conn.private[:api_access_token], renewal_token: conn.private[:api_renewal_token]}})

        {:error, conn} ->
          invalid_login(conn)
      end
    else
      invalid_login(conn)
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
