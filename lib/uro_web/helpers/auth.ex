defmodule UroWeb.Helpers.Auth do

  def signed_in?(conn) do
    if Pow.Plug.current_user(conn) do
      true
    end
  end

  def get_user(conn) do
    Pow.Plug.current_user(conn)
  end

  def session_username(conn) do
    user = get_user(conn)
    if user do
      if user.username do
        user.username
      else
        "[NULL]"
      end
    end
  end

    def session_display_name(conn) do
      user = get_user(conn)
      if user do
        if user.display_name do
          user.display_name
        else
          "[NULL]"
        end
      end
  end
end
