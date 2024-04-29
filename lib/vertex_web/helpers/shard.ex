defmodule VertexWeb.Helpers.Shard do
  use VertexWeb, :controller

  @doc false
  def get_api_shard_public(shard) do
    %{
      user: VertexWeb.Helpers.User.get_api_user_public(shard.user),
      address: to_string(shard.address),
      port: shard.port,
      map: to_string(shard.map),
      name: to_string(shard.name),
      current_users: shard.current_users,
      max_users: shard.max_users
    }
  end

  @doc false
  def get_api_shard_list_public(shard_list) do
    Enum.map(shard_list, fn x -> get_api_shard_public(x) end)
  end
end
