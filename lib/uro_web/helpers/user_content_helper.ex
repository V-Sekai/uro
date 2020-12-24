defmodule UroWeb.Helpers.UserContentHelper do

  def get_correct_user_content_params(conn, user_content_params, user_content_data_filename_param, user_content_data_preview_param) do
    user_content_data = Map.get(user_content_params, user_content_data_filename_param)
    user_content_preview = Map.get(user_content_params, user_content_data_preview_param)

    %{
      "name" => Map.get(user_content_params, "name", ""),
      "description" => Map.get(user_content_params, "description", ""),
      "user_content_data" => user_content_data,
      "user_content_preview" => user_content_preview,
      "uploader_id" => conn.assigns[:current_user].id
    }
  end
end
