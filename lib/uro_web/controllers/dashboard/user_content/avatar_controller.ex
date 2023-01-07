defmodule UroWeb.Dashboard.UserContent.AvatarController do
  use UroWeb, :controller

  alias Uro.UserContent
  alias Uro.UserContent.Avatar

  @user_content_data_param_name "user_content_data"
  @user_content_preview_param_name "user_content_preview"

  def index(conn, params) do
    page =
      UserContent.list_avatars_uploaded_by_with_pagination(params, conn.assigns[:current_user])

    render(conn, "index.html", page: page)
  end

  def new(conn, _params) do
    changeset = UserContent.change_avatar(%Avatar{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"avatar" => avatar_params}) do
    case UserContent.create_avatar(
           UroWeb.Helpers.UserContentHelper.get_correct_user_content_params(
             conn,
             avatar_params,
             @user_content_data_param_name,
             @user_content_preview_param_name
           )
         ) do
      {:ok, avatar} ->
        conn
        |> put_flash(:info, gettext("Avatar created successfully."))
        |> redirect(to: Routes.dashboard_avatar_path(conn, :show, avatar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar_uploaded_by_user!(id, conn.assigns[:current_user])
    render(conn, "show.html", avatar: avatar)
  end

  def edit(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar_uploaded_by_user!(id, conn.assigns[:current_user])
    changeset = UserContent.change_avatar(avatar)
    render(conn, "edit.html", avatar: avatar, changeset: changeset)
  end

  def update(conn, %{"id" => id, "avatar" => avatar_params}) do
    avatar = UserContent.get_avatar_uploaded_by_user!(id, conn.assigns[:current_user])

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
    case UserContent.get_avatar_uploaded_by_user!(id, conn.assigns[:current_user]) do
      %Uro.UserContent.Avatar{} = avatar ->
        case UserContent.delete_avatar(avatar) do
          {:ok, _avatar} ->
            conn
            |> put_flash(:info, gettext("Avatar deleted successfully."))
            |> redirect(to: Routes.dashboard_avatar_path(conn, :index))

          {:error, %Ecto.Changeset{}} ->
            conn
            |> put_flash(:info, gettext("Could not delete avatar."))
            |> redirect(to: Routes.dashboard_avatar_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:info, gettext("Could not delete avatar."))
        |> redirect(to: Routes.dashboard_avatar_path(conn, :index))
    end
  end
end
