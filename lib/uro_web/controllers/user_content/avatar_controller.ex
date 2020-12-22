defmodule UroWeb.UserContent.AvatarController do
  use UroWeb, :controller

  alias Uro.UserContent
  alias Uro.UserContent.Avatar

  @user_content_data_param_name "user_content_data"
  @user_content_preview_param_name "user_content_preview"

  def index(conn, _params) do
    avatars = UserContent.list_avatars_uploaded_by(conn.assigns[:current_user])
    render(conn, "index.html", avatars: avatars)
  end

  def new(conn, _params) do
    changeset = UserContent.change_avatar(%Avatar{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"avatar" => avatar_params}) do
    case UserContent.create_avatar(
      UroWeb.Helpers.UserContentHelper.get_correct_user_content_params(conn, avatar_params, @user_content_data_param_name, @user_content_preview_param_name)) do
      {:ok, avatar} ->
        conn
        |> put_flash(:info, gettext("Avatar created successfully."))
        |> redirect(to: Routes.dashboard_avatar_path(conn, :show, avatar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar!(id)
    render(conn, "show.html", avatar: avatar)
  end

  def edit(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar!(id)
    changeset = UserContent.change_avatar(avatar)
    render(conn, "edit.html", avatar: avatar, changeset: changeset)
  end

  def update(conn, %{"id" => id, "avatar" => avatar_params}) do
    avatar = UserContent.get_avatar!(id)

    case UserContent.update_avatar(avatar, avatar_params) do
      {:ok, avatar} ->
        conn
        |> put_flash(:info, gettext("Avatar updated successfully."))
        |> redirect(to: Routes.dashboard_avatar_path(conn, :show, avatar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", avatar: avatar, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar!(id)
    {:ok, _avatar} = UserContent.delete_avatar(avatar)

    conn
    |> put_flash(:info, gettext("Avatar deleted successfully."))
    |> redirect(to: Routes.dashboard_avatar_path(conn, :index))
  end
end
