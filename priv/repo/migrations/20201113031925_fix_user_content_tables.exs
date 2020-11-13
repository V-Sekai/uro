defmodule Uro.Repo.Migrations.FixUserContentTables do
  use Ecto.Migration

  def up do
    rename table("avatars"), :uploader_id, to: :uploader
    rename table("maps"), :uploader_id, to: :uploader
    rename table("props"), :uploader_id, to: :uploader
  end

  def down do
    rename table("avatars"), :uploader, to: :uploader_id
    rename table("maps"), :uploader, to: :uploader_id
    rename table("props"), :uploader, to: :uploader_id
  end
end
