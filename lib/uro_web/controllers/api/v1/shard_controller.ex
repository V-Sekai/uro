defmodule UroWeb.API.V1.ShardController do
  use UroWeb, :controller
  use UroWeb.Helpers.API
  alias Uro.VSekai

  def ensure_has_address(conn, params) do
    if !Map.has_key?(params, "address") do
      Map.put(params, "address", to_string(:inet_parse.ntoa(conn.remote_ip)))
    else
      params
    end
  end

  def ensure_user_is_current_user_or_nil(conn, params) do
    if UroWeb.Helpers.Auth.signed_in?(conn) do
      Map.put(params, "user_id", UroWeb.Helpers.Auth.get_current_user(conn).id)
    else
      Map.put(params, "user_id", nil)
    end
  end

  def can_connection_modify_shard(conn, shard) do
    if shard.user != nil and
         UroWeb.Helpers.Auth.signed_in?(conn) and
         shard.user == UroWeb.Helpers.Auth.get_current_user(conn) do
      true
    else
      if shard.user == nil and
           shard.address == to_string(:inet_parse.ntoa(conn.remote_ip)) do
        true
      else
        false
      end
    end
  end

  def index(conn, _params) do
    shards = VSekai.list_fresh_shards()

    conn
    |> put_status(200)
    |> json(%{data: %{shards: UroWeb.Helpers.Shard.get_api_shard_list_public(shards)}})
  end

  def create(conn, %{"shard" => shard_params}) do
    shard_params =
      conn
      |> ensure_has_address(shard_params)

    conn
    |> ensure_user_is_current_user_or_nil(shard_params)
    |> VSekai.create_shard()
    |> case do
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

    if can_connection_modify_shard(conn, shard) do
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

  def update(conn, %{"id" => id}) do
    update(conn, %{"id" => id, "shard" => %{}})
  end

  def delete(conn, %{"id" => id}) do
    shard =
      Uro.VSekai.Shard
      |> Repo.get!(id)
      |> Repo.preload(:user)

    if can_connection_modify_shard(conn, shard) do
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
