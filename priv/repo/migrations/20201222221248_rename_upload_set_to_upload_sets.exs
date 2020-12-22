defmodule Uro.Repo.Migrations.RenameUploadSetToUploadSets do
  use Ecto.Migration

  def change do
    rename table(:upload_set), to: table(:upload_sets)
  end
end
