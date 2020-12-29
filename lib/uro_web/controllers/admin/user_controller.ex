defmodule UroWeb.Admin.UserController do
  use UroWeb, :controller

  alias Uro.Accounts
  alias Uro.Accounts.User

  def index(conn, params) do
    users = Accounts.list_users_admin(params)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user_as_admin(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: Routes.admin_user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: Routes.admin_user_path(conn, :index))
  end

  @spec lock(Conn.t(), map()) :: Conn.t()
  def lock(%{assigns: %{user: user}} = conn, _params) do
    case Uro.Accounts.lock(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("User has been locked."))
        |> redirect(to: "/")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("User couldn't be locked."))
        |> redirect(to: "/")
    end
  end
end
