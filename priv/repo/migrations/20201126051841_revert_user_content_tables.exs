defmodule Uro.Repo.Migrations.RevertUserContentTables do
  use Ecto.Migration

  def change do
    rename table("avatars"), :uploader, to: :uploader_id
    rename table("maps"), :uploader, to: :uploader_id
    rename table("props"), :uploader, to: :uploader_id
  end
end
