defmodule VertexWeb.API.V1.RegistrationController do
  use VertexWeb, :controller

  alias Ecto.Changeset
  alias Plug.Conn
  alias VertexWeb.ErrorHelpers

  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, _params) do
    conn
    |> VertexWeb.Helpers.Auth.get_current_user()
    |> case do
      nil ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: gettext("Couldn't get current user")}})

      user ->
        conn
        |> json(%{data: %{user: user}})
    end
  end

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Vertex.Accounts.create_user(user_params)
    |> case do
      {:ok, _user, conn} ->
        conn
        |> VertexWeb.Helpers.Auth.verify_confirmed_or_send_confirmation_email()
        |> case do
          _ ->
            conn
            |> json(%{data: %{}})
        end

      {:error, changeset, conn} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: gettext("Couldn't create user"), errors: errors}})
    end
  end
end
