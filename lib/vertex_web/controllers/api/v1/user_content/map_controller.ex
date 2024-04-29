defmodule VertexWeb.API.V1.UserContent.MapController do
  use VertexWeb, :controller
  use VertexWeb.Helpers.API

  alias Vertex.UserContent

  def index(conn, _params) do
    maps = UserContent.list_public_maps()

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        maps:
          VertexWeb.Helpers.UserContentHelper.get_api_user_content_list(maps, %{
            merge_uploader_id: true
          })
      }
    })
  end

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_map!()
    |> case do
      %Vertex.UserContent.Map{} = map ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            map:
              VertexWeb.Helpers.UserContentHelper.get_api_user_content(
                map,
                %{merge_uploader_id: true, merge_is_public: true}
              )
          }
        })

      _ ->
        conn
        |> put_status(400)
    end
  end
end
