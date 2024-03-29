defmodule UroWeb.API.V1.Dashboard.UserContent.AvatarController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.UserContent

  @user_content_data_param_name "user_content_data"
  @user_content_preview_param_name "user_content_preview"

  def index(conn, _params) do
    avatars = UserContent.list_avatars_uploaded_by(conn.assigns[:current_user])

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        avatars:
          UroWeb.Helpers.UserContentHelper.get_api_user_content_list(
            avatars,
            %{merge_is_public: true, merge_inserted_at: true, merge_updated_at: true}
          )
      }
    })
  end

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_avatar_uploaded_by_user!(conn.assigns[:current_user])
    |> case do
      %Uro.UserContent.Avatar{} = avatar ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            avatar:
              UroWeb.Helpers.UserContentHelper.get_api_user_content(
                avatar,
                %{merge_is_public: true, merge_inserted_at: true, merge_updated_at: true}
              )
          }
        })

      _ ->
        conn
        |> put_status(400)
    end
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
        |> put_status(200)
        |> json(%{data: %{id: to_string(avatar.id)}})

      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end

  def update(conn, %{"id" => id, "avatar" => avatar_params}) do
    avatar = UserContent.get_avatar_uploaded_by_user!(id, conn.assigns[:current_user])

    case UserContent.update_avatar(avatar, avatar_params) do
      {:ok, avatar} ->
        conn
        |> put_status(200)
        |> json(%{data: %{id: to_string(avatar.id)}})

      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end

  def delete(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar_uploaded_by_user!(id, conn.assigns[:current_user])

    case UserContent.delete_avatar(avatar) do
      {:ok, _avatar} ->
        conn
        |> put_status(200)
        |> json(%{})

      {:error, %Ecto.Changeset{}} ->
        conn
        |> json_error(400)
    end
  end
end
