defmodule UroWeb.Helpers.UserContentHelper do

  @doc false
  defp check_can_upload_avatars_field(%{can_upload_avatars: true}) do
    true
  end

  @doc false
  defp check_can_upload_avatars_field(_) do
    false
  end

  @doc false
  defp check_can_upload_maps_field(%{can_upload_maps: true}) do
    true
  end

  @doc false
  defp check_can_upload_maps_field(_) do
    false
  end

  @doc false
  defp check_can_upload_props_field(%{can_upload_props: true}) do
    true
  end

  @doc false
  defp check_can_upload_props_field(_) do
    false
  end

  @doc false
  def has_avatar_upload_permission?(user) do
    user
    |> UroWeb.Helpers.Auth.get_user_privilege_ruleset
    |> check_can_upload_avatars_field
  end

  @doc false
  def has_map_upload_permission?(user) do
    user
    |> UroWeb.Helpers.Auth.get_user_privilege_ruleset
    |> check_can_upload_maps_field
  end

  @doc false
  def has_prop_upload_permission?(user) do
    user
    |> UroWeb.Helpers.Auth.get_user_privilege_ruleset
    |> check_can_upload_props_field
  end

  @doc false
  def session_has_avatar_upload_permission?(conn) do
    has_avatar_upload_permission?(conn.assigns[:current_user])
  end

  @doc false
  def session_has_map_upload_permission?(conn) do
    has_map_upload_permission?(conn.assigns[:current_user])
  end

  @doc false
  def session_has_prop_upload_permission?(conn) do
    has_prop_upload_permission?(conn.assigns[:current_user])
  end

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
