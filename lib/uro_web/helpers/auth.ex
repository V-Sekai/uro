defmodule UroWeb.Helpers.Auth do

  def signed_in?(conn) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    if user_id, do: Uro.Repo.get(Uro.Accounts.User, user_id)
  end

  def get_user(conn) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    if user_id do
      Uro.Repo.get(Uro.Accounts.User, user_id)
    end
  end

  def session_username(conn) do
    user = get_user(conn)
    if user do
      user.username
    end
  end

    def session_display_name(conn) do
      user = get_user(conn)
      if user do
        user.display_name
      end
  end
end
