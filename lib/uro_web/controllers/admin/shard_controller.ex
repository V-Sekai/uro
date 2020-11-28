defmodule UroWeb.Admin.ShardController do
  use UroWeb, :controller

  alias Uro.VSekai
  alias Uro.VSekai.Shard

  def index(conn, _params) do
    shards = VSekai.list_shards()
    render(conn, "index.html", shards: shards)
  end

  def new(conn, _params) do
    changeset = VSekai.change_shard(%Shard{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shard" => shard_params}) do
    case VSekai.create_shard(shard_params) do
      {:ok, shard} ->
        conn
        |> put_flash(:info, gettext("Shard created successfully."))
        |> redirect(to: Routes.admin_shard_path(conn, :show, shard))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shard = VSekai.get_shard!(id)
    render(conn, "show.html", shard: shard)
  end

  def edit(conn, %{"id" => id}) do
    shard = VSekai.get_shard!(id)
    changeset = VSekai.change_shard(shard)
    render(conn, "edit.html", shard: shard, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shard" => shard_params}) do
    shard = VSekai.get_shard!(id)

    case VSekai.update_shard(shard, shard_params) do
      {:ok, shard} ->
        conn
        |> put_flash(:info, gettext("Shard updated successfully."))
        |> redirect(to: Routes.admin_shard_path(conn, :show, shard))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", shard: shard, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shard = VSekai.get_shard!(id)
    {:ok, _shard} = VSekai.delete_shard(shard)

    conn
    |> put_flash(:info, gettext("Shard deleted successfully."))
    |> redirect(to: Routes.admin_shard_path(conn, :index))
  end
end
