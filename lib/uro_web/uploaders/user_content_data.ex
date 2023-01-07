defmodule Uro.Uploaders.UserContentData do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extension_whitelist ~w(.scn)

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  # Override the persisted filenames:
  def filename(version, {_file, scope}) do
    "#{scope.id}_#{version}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    "uploads/"
  end
end
