defmodule Uro.AvatarController do
  use Uro, :controller
  use Uro.Helpers.API
  use OpenApiSpex.ControllerSpecs

  alias Uro.UserContent

  def index(conn, _params) do
    avatars = UserContent.list_public_avatars()

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        avatars:
          Uro.Helpers.UserContentHelper.get_api_user_content_list(avatars, %{
            merge_uploader_id: true
          })
      }
    })
  end

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_avatar!()
    |> case do
      %Uro.UserContent.Avatar{} = avatar ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            avatar:
              Uro.Helpers.UserContentHelper.get_api_user_content(
                avatar,
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
