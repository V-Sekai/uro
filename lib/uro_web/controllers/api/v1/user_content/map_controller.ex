defmodule UroWeb.API.V1.UserContent.MapController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.UserContent

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_map!
    |> case do
      map ->
        conn
        |> put_status(200)
        |> json(%{data: %{map: UroWeb.Helpers.UserContentHelper.get_api_user_content(map)}})
      _ ->
        conn
        |> put_status(400)
    end
  end
end
