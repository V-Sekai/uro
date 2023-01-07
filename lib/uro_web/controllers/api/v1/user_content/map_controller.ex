defmodule UroWeb.API.V1.UserContent.MapController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.UserContent

  def index(conn, _params) do
    maps = UserContent.list_public_maps()

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        maps:
          UroWeb.Helpers.UserContentHelper.get_api_user_content_list(maps, %{
            merge_uploader_id: true
          })
      }
    })
  end

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_map!()
    |> case do
      %Uro.UserContent.Map{} = map ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            map:
              UroWeb.Helpers.UserContentHelper.get_api_user_content(
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
