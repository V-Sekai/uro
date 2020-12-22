defmodule UroWeb.Helpers.UserContentHelper do

  def get_or_create_upload_set_for_user(user) do
    user
      |> Uro.Repo.preload([:upload_set])
      |> case do
        nil ->
          Uro.Accounts.create_upload_set_for_user(user)
        user ->
          user.upload_set
    end
  end

  def get_correct_user_content_params(conn, user_content_params, user_content_data_filename_param, user_content_data_preview_param) do
    upload_set = get_or_create_upload_set_for_user(conn.assigns[:current_user])

    user_content_data = Map.get(user_content_params, user_content_data_filename_param)
    user_content_preview = Map.get(user_content_params, user_content_data_preview_param)

    %{
      "name" => Map.get(user_content_params, "name", ""),
      "description" => Map.get(user_content_params, "description", ""),
      "user_content_data" => user_content_data,
      "user_content_preview" => user_content_preview,
      "uploader_id" => upload_set.id
    }
  end
end
