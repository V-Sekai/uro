defmodule VertexWeb.API.V1.UserController do
  use VertexWeb, :controller
  use VertexWeb.Helpers.API

  alias Vertex.Accounts

  def show(conn, %{"id" => id}) do
    id
    |> Accounts.get_user!()
    |> case do
      %Accounts.User{} = user ->
        conn
        |> put_status(200)
        |> json(%{data: %{user: VertexWeb.Helpers.User.get_api_user_public(user)}})

      _ ->
        conn
        |> put_status(400)
    end
  end
end
