defmodule UroWeb.API.V1.UserController do
  @moduledoc false

  use UroWeb, :controller
  use UroWeb.Helpers.API
  use OpenApiSpex.ControllerSpecs

  import UroWeb.Helpers.User

  alias OpenApiSpex.Schema
  alias Uro.Accounts
  alias Uro.Plug.Authentication
  alias UroWeb.Helpers.API.ErrorObject
  alias UroWeb.Helpers.User.UserObject

  tags(["users"])
  security(default_security())

  operation(:show,
    operation_id: "getUser",
    summary: "Get a specific user.",
    parameters: [
      id: [
        in: :path,
        description: "The User ID. Use `@me` to get the current user.",
        schema: %Schema{type: :string, default: "@me"}
      ],
      username: [
        in: :query,
        description: "Search for a user by username.",
        schema: %Schema{type: :boolean}
      ]
    ],
    responses: [
      ok: {
        "",
        "application/json",
        UserObject
      },
      not_found: {
        "User not found",
        "application/json",
        ErrorObject
      }
    ]
  )

  def show(conn, %{"id" => "@me"}) do
    conn
    |> put_status(200)
    |> json(
      Authentication.current_user(conn)
      |> transform_user()
    )
  end

  def show(conn, %{"id" => username, "username" => "true"} = a) do
    username
    |> Accounts.get_by_username()
    |> case do
      %Accounts.User{} = user ->
        conn
        |> put_status(200)
        |> json(transform_user(user))

      _ ->
        json_error(conn, "User not found", status: 404)
    end
  end

  def show(conn, %{"id" => id}) do
    id
    |> Accounts.get_user!()
    |> case do
      %Accounts.User{} = user ->
        conn
        |> put_status(200)
        |> json(transform_user(user))

      _ ->
        json_error(conn, "User not found", status: 404)
    end
  end
end
