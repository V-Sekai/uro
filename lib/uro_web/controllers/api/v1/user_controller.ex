defmodule UroWeb.API.V1.UserController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.Accounts

  def show(conn, %{"id" => id}) do
    id
    |> Accounts.get_user!()
    |> case do
      %Accounts.User{} = user ->
        conn
        |> put_status(200)
        |> json(%{data: %{user: UroWeb.Helpers.User.get_api_user_public(user)}})

      _ ->
        conn
        |> put_status(400)
    end
  end
end
