defmodule UroWeb.API.V1.AvatarController do
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Uro.UserContent

  @user_content_data_param_name "user_content_data"
  @user_content_preview_param_name "user_content_preview"

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_avatar!
    |> case do
      {:ok, avatar} ->
        conn
        |> put_status(200)
        |> json(%{data: %{avatar: avatar}})
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_status(400)
    end
  end

  def create(conn, %{"avatar" => avatar_params}) do
    case UserContent.create_avatar(
      UroWeb.Helpers.UserContentHelper.get_correct_user_content_params(conn, avatar_params, @user_content_data_param_name, @user_content_preview_param_name)) do
      {:ok, avatar} ->
        conn
        |> put_status(200)
        |> json(%{data: %{id: to_string(avatar.id)}})

        {:error, %Ecto.Changeset{}} ->
          conn
          |> json_error(400)
    end
  end
end
