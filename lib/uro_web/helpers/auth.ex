defmodule UroWeb.Helpers.Auth do

  def validate_user_params(user_params) do
    required_keys = ["username_or_email", "password"]
    |> Enum.all?(&(Map.has_key?(user_params, &1)))
  end

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
