defmodule UroWeb.API.V1.Dashboard.UserContent.MapController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.UserContent

  @user_content_data_param_name "user_content_data"
  @user_content_preview_param_name "user_content_preview"

  def index(conn, _params) do
    maps = UserContent.list_maps_uploaded_by(conn.assigns[:current_user])

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        maps:
          UroWeb.Helpers.UserContentHelper.get_api_user_content_list(
            maps,
            %{merge_is_public: true, merge_inserted_at: true, merge_updated_at: true}
          )
      }
    })
  end

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_map_uploaded_by_user!(conn.assigns[:current_user])
    |> case do
      %Uro.UserContent.Map{} = map ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            map:
              UroWeb.Helpers.UserContentHelper.get_api_user_content(
                map,
                %{merge_is_public: true, merge_inserted_at: true, merge_updated_at: true}
              )
          }
        })

      _ ->
        conn
        |> put_status(400)
    end
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
        |> put_status(200)
        |> json(%{data: %{id: to_string(map.id)}})

      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end

  def update(conn, %{"id" => id, "map" => map_params}) do
    map = UserContent.get_map_uploaded_by_user!(id, conn.assigns[:current_user])

    case UserContent.update_map(map, map_params) do
      {:ok, map} ->
        conn
        |> put_status(200)
        |> json(%{data: %{id: to_string(map.id)}})

      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end

  def delete(conn, %{"id" => id}) do
    map = UserContent.get_map_uploaded_by_user!(id, conn.assigns[:current_user])

    case UserContent.delete_map(map) do
      {:ok, _map} ->
        conn
        |> put_status(200)
        |> json(%{})

      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end
end
