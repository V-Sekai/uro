defmodule UroWeb.API.V1.AvatarController do
  use UroWeb, :controller
  alias Uro.UserContent

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_avatar!
    |> case do
      avatar ->
        conn
        |> put_status(200)
        |> json(%{data: %{avatar: avatar}})
      nil ->
        conn
        |> put_status(400)
    end
  end
end
