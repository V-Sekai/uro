defmodule UroWeb.APIAuthErrorHandler do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Plug.Conn

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :not_authenticated) do
    json_error(conn, "Invalid credentials", status: 401)
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :already_authenticated) do
    json_error(conn, "Conflicting credentials", status: 401)
  end

  # This is a typo, but we need to keep it for compatibility with Pow.
  def call(conn, :insufficent_permission), do: call(conn, :insufficient_permission)

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :insufficient_permission) do
    json_error(conn, "Insufficient permission", status: 401)
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :account_locked) do
    json_error(conn, "Account locked", status: 401)
  end
end
