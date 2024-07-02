defmodule Uro.MapController do
  use Uro, :controller
  use OpenApiSpex.ControllerSpecs
  use Uro.Helpers.API

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
    summary: "Get a specific map.",
    parameters: [
      id: [
        in: :path,
        description: "The User ID. Use `@me` to get the current user.",
        schema: %Schema{type: :string, default: "@me"}
      ]
    ],
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      },
      not_found: {
        "User not found",
        "application/json",
        %Schema{type: :null}
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
