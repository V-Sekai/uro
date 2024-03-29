defmodule UroWeb.Dashboard.UserContent.MapController do
  use UroWeb, :controller

  alias Uro.UserContent
  alias Uro.UserContent.Map

  @user_content_data_param_name "user_content_data"
  @user_content_preview_param_name "user_content_preview"

  def index(conn, params) do
    page = UserContent.list_maps_uploaded_by_with_pagination(params, conn.assigns[:current_user])
    render(conn, "index.html", page: page)
  end

  def new(conn, _params) do
    changeset = UserContent.change_map(%Map{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"map" => map_params}) do
    case UserContent.create_map(
           UroWeb.Helpers.UserContentHelper.get_correct_user_content_params(
             conn,
             map_params,
             @user_content_data_param_name,
             @user_content_preview_param_name
           )
         ) do
      {:ok, map} ->
        conn
        |> put_flash(:info, gettext("Map created successfully."))
        |> redirect(to: Routes.dashboard_map_path(conn, :show, map))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    map = UserContent.get_map_uploaded_by_user!(id, conn.assigns[:current_user])
    render(conn, "show.html", map: map)
  end

  def edit(conn, %{"id" => id}) do
    map = UserContent.get_map_uploaded_by_user!(id, conn.assigns[:current_user])
    changeset = UserContent.change_map(map)
    render(conn, "edit.html", map: map, changeset: changeset)
  end

  def update(conn, %{"id" => id, "map" => map_params}) do
    map = UserContent.get_map_uploaded_by_user!(id, conn.assigns[:current_user])

    case UserContent.update_map(map, map_params) do
      {:ok, map} ->
        conn
        |> put_flash(:info, gettext("Map updated successfully."))
        |> redirect(to: Routes.dashboard_map_path(conn, :show, map))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", map: map, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case UserContent.get_map_uploaded_by_user!(id, conn.assigns[:current_user]) do
      %Uro.UserContent.Map{} = map ->
        case UserContent.delete_map(map) do
          {:ok, _map} ->
            conn
            |> put_flash(:info, gettext("Map deleted successfully."))
            |> redirect(to: Routes.dashboard_map_path(conn, :index))

          {:error, %Ecto.Changeset{}} ->
            conn
            |> put_flash(:info, gettext("Could not delete map."))
            |> redirect(to: Routes.dashboard_map_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:info, gettext("Could not delete map."))
        |> redirect(to: Routes.dashboard_map_path(conn, :index))
    end
  end
end
