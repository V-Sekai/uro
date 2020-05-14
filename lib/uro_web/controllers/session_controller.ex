defmodule UroWeb.SessionController do
  use UroWeb, :controller

  alias Uro.Accounts
  alias Uro.Accounts.User

  def new(conn, _params) do
    render(conn, "sign_in.html")
  end

  def create(conn, %{"session" => auth_params} = _params) do
    user = Accounts.get_by_username_or_email(auth_params["username_or_email"])

    case Bcrypt.check_pass(user, auth_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Signed in successfully.")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _} ->
        render(conn, "sign_up.html")
    end
  end

  def delete(conn, _params) do
      conn
      |> delete_session(:current_user_id)
      |> put_flash(:info, "Signed out successfully.")
      |> redirect(to: Routes.page_path(conn, :index))
  end
end
