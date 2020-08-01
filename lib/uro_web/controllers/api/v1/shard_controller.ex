defmodule UroWeb.API.V1.ShardController do
  use UroWeb, :controller
  use UroWeb.Helpers.API
  alias Uro.VSekai

  def index(conn, _params) do
    shards = VSekai.list_fresh_shards()
    conn
    |> put_status(200)
    |> json(%{data: %{shards: shards}})
  end

  def create(conn, %{"shard" => shard_params}) do
    if !Map.has_key?(shard_params, "address") do
      shard_params = Map.put(shard_params, "address", to_string(:inet_parse.ntoa(conn.remote_ip)))
    end

    case VSekai.create_shard(shard_params) do
      {:ok, shard} ->
        conn
        |> put_status(200)
        |> json(%{data: %{id: to_string(shard.id)}})
      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end

  def update(conn, %{"id" => id, "shard" => shard_params}) do
    shard = VSekai.get_shard!(id)
    if shard.address == to_string(:inet_parse.ntoa(conn.remote_ip)) do
      case VSekai.update_shard(shard, shard_params) do
        {:ok, shard} ->
          conn
          |> put_status(200)
          |> json(%{data: %{id: to_string(shard.id)}})
        {:error, %Ecto.Changeset{}} ->
          conn
          |> json_error(400)
      end
    else
      conn
      |> json_error(400)
    end
  end

  def delete(conn, %{"id" => id}) do
    shard = VSekai.get_shard!(id)
    if shard.address == to_string(:inet_parse.ntoa(conn.remote_ip)) do
      case VSekai.delete_shard(shard) do
        {:ok, shard} ->
          conn
          |> put_status(200)
          |> json(%{data: %{id: to_string(shard.id)}})
        {:error, %Ecto.Changeset{}} ->
          conn
          |> json_error(400)
      end
    else
      conn
      |> json_error(400)
    end
  end
end
