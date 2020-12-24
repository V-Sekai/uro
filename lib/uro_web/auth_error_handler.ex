defmodule UroWeb.AuthErrorHandler do
  use UroWeb, :controller
  alias Plug.Conn

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :not_authenticated) do
    conn
    |> put_flash(:error, gettext("You are not signed in"))
    |> redirect(to: Routes.signin_path(conn, :new))
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :already_authenticated) do
    conn
    |> put_flash(:error, gettext("You're already authenticated"))
    |> redirect(to: Routes.page_path(conn, :index))
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :insufficent_permission) do
    conn
    |> put_flash(:error, gettext("Insufficent permission"))
    |> redirect(to: Routes.page_path(conn, :index))
  end

  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, :account_locked) do
    conn
    |> put_flash(:error, gettext("Sorry, your account is locked."))
    |> redirect(to: Routes.signin_path(conn, :new))
  end
end
