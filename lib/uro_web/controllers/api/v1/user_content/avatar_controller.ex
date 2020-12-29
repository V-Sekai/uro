defmodule UroWeb.API.V1.UserContent.AvatarController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.UserContent

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_avatar!
    |> case do
      %Uro.UserContent.Avatar{} = avatar ->
        conn
        |> put_status(200)
        |> json(%{data: %{avatar: UroWeb.Helpers.UserContentHelper.get_api_user_content(avatar)}})
      _ ->
        conn
        |> put_status(400)
    end
  end
end
