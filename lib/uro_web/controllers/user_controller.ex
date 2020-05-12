defmodule UroWeb.UserController do
  use UroWeb, :controller

  alias Uro.Accounts
  alias Uro.Accounts.User

  def sign_in(conn, _params) do

  end

  def create_session(conn, %{"session" => auth_params} = _params) do
  end

  def sign_up(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "sign_up.html", changeset: changeset)
  end

  def create_user(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "sign_up.html", changeset: changeset)
    end
  end
end
