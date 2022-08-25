defmodule UroWeb.RegistrationController do
  use UroWeb, :controller
  use UroWeb.Helpers.Auth

  def show(conn, _params) do
    conn
    |> UroWeb.Helpers.Auth.get_current_user()
    |> case do
      user ->
        conn
        |> render("show.html", user: user)
    end
  end

  def new(conn, _params) do
    conn
    |> Pow.Plug.change_user()
    |> case do
      changeset ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> Uro.Accounts.create_user(user_params)
    |> case do
      {:ok, _user, conn} ->
        conn
        |> UroWeb.Helpers.Auth.verify_confirmed_or_send_confirmation_email()
        |> case do
          {:ok, conn} ->
            conn
            |> put_flash(:info, gettext("Welcome!"))
            |> redirect(to: Routes.page_path(conn, :index))

          {:failed, conn} ->
            conn
            |> Pow.Plug.delete()
            |> put_flash(:info, gettext("An email has been sent to you to confirm your account!"))
            |> redirect(to: Routes.signup_path(conn, :new))
        end

      {:error, changeset, conn} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    conn
    |> Pow.Plug.change_user()
    |> case do
      changeset ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"user" => user_params}) do
    conn
    |> Uro.Accounts.update_current_user(user_params)
    |> case do
      {:ok, _user, conn} ->
        conn
        |> put_flash(:info, gettext("Updated profile successfully!"))
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset, conn} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
