defmodule UroWeb.UserController do
  use UroWeb, :controller

  alias Uro.Accounts
  alias Uro.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "sign_up.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "sign_up.html", changeset: changeset)
    end
  end
end
