defmodule UroWeb.SessionController do
  use UroWeb, :controller
  import UroWeb.Helpers.Auth

  def invalid_login(conn) do
    changeset = Pow.Plug.change_user(conn, conn.params["user"])

    conn
    |> put_flash(:info, "Invalid email or password")
    |> render("new.html", changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    if UroWeb.Helpers.Auth.validate_user_params(user_params) do
      user = Uro.Accounts.get_by_username_or_email(user_params["username_or_email"] |> String.downcase)

      if user do
        final_params = %{"email" => user.email, "password" => user_params["password"]}

        conn
        |> Pow.Plug.authenticate_user(final_params)
        |> case do
          {:ok, conn} ->
            conn
            |> put_flash(:info, "Welcome back!")
            |> redirect(to: Routes.page_path(conn, :index))

          {:error, conn} ->
            invalid_login(conn)
        end
      else
        invalid_login(conn)
      end
    else
      invalid_login(conn)
    end
  end

  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
