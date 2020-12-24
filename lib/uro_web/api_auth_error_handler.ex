defmodule UroWeb.APIAuthErrorHandler do
  use UroWeb, :controller
  alias Plug.Conn

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :not_authenticated) do
    conn
    |> put_status(401)
    |> json(%{error: %{code: 401, message: "Not authenticated"}})
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :already_authenticated) do
    conn
    |> put_status(401)
    |> json(%{error: %{code: 401, message: "Already authenticated"}})
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :insufficent_permission) do
    conn
    |> put_status(401)
    |> json(%{error: %{code: 401, message: "Insufficent permission"}})
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :account_locked) do
    conn
    |> put_status(401)
    |> json(%{error: %{code: 401, message: "Account locked"}})
  end
end
