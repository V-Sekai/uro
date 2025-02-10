defmodule Uro.MapController do
  use Uro, :controller

  alias OpenApiSpex.Schema
  alias Uro.UserContent

  tags(["maps"])

  def index(conn, _params) do
    maps = UserContent.list_public_maps()

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        maps:
          Uro.Helpers.UserContentHelper.get_api_user_content_list(maps, %{
            merge_uploader_id: true
          })
      }
    })
  end

  operation(:show,
    operation_id: "getMap",
    summary: "Get Map",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

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
              Uro.Helpers.UserContentHelper.get_api_user_content(
                map,
                %{merge_uploader_id: true, merge_is_public: true}
              )
          }
        })

      _ ->
        put_status(
          conn,
          400
        )
    end
  end
end
