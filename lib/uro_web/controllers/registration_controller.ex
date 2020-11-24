defmodule UroWeb.RegistrationController do
  use UroWeb, :controller
  use UroWeb.Helpers.Auth

  def show(conn, _params) do
    conn
    |> UroWeb.Helpers.Auth.get_current_user
    |> case do
      user ->
        conn
        |> render("show.html", user: user)
    end
  end

  def new(conn, _params) do
    conn
    |> Pow.Plug.change_user
    |> case do
      changeset ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
      {:ok,_user, conn} ->
        conn
        |> put_flash(:info, gettext("Welcome!"))
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset, conn} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    conn
    |> put_flash(:error, gettext("Profile editing is not currently available."))
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
