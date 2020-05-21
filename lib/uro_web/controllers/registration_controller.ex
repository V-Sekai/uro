defmodule UroWeb.RegistrationController do
  use UroWeb, :controller

  def new(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
      {:ok, user, conn} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset, conn} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    conn
    |> put_flash(:error, "Profile editing is not currently available.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
