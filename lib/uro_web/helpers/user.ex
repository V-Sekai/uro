defmodule UroWeb.Helpers.User do
  use UroWeb, :controller

  @doc false
  def get_api_user_public(nil) do
    nil
  end

  @doc false
  def get_api_user_public(user) do
    %{
      id: to_string(user.id),
      username: to_string(user.username),
      display_name: to_string(user.display_name)
    }
  end

  @doc false
  def get_api_user_list_public(user_list) do
    Enum.map(user_list, fn x -> get_api_user_public(x) end)
  end
end
