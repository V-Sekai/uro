defmodule UroWeb.Helpers.UserContentHelper do
  def store_upload(upload_plug) do
    case upload_plug do
      %Plug.Upload{} ->
        upload_plug
        |> Uro.Uploaders.UserContent.store
        |> case do
          {:ok, filename} -> filename
          _ -> nil
        end
      _ -> nil
    end
  end

  def get_or_create_upload_set_for_user(user) do
    user
      |> Uro.Repo.preload(upload_set: [:upload_set])
      |> case do
        nil -> Uro.Accounts.create_upload_set_for_user(user)
      end

    user.upload_set
  end

  def get_correct_user_content_params(conn, user_content_params, user_content_filename_param) do
    upload_set = get_or_create_upload_set_for_user(conn.assigns[:current_user])

    %{
      "name" => Map.get(user_content_params, "name", ""),
      "description" => Map.get(user_content_params, "description", ""),
      "url" => store_upload(Map.get(user_content_params, user_content_filename_param)),
      "uploader_id" => upload_set.id
    }
  end
end
