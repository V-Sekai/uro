defmodule Uro.Uploaders.UserContentData do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extension_whitelist ~w(.scn)

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
   end

  # Override the persisted filenames:
  def filename(_version, {_file, scope}) do
    "#{scope.id}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    case scope do
      %Uro.UserContent.Avatar{} ->
        "uploads/user_content/#{scope.uploader_id}/avatars/"
      %Uro.UserContent.Map{} ->
        "uploads/user_content/#{scope.uploader_id}/maps/"
      %Uro.UserContent.Prop{} ->
        "uploads/user_content/#{scope.uploader_id}/props/"
    end
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
