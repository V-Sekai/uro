defmodule Uro.Repo.Migrations.DropUploaderIds do
  use Ecto.Migration

  def change do
    alter table(:avatars) do
      remove :uploader_id
    end

    alter table(:maps) do
      remove :uploader_id
    end

    alter table(:props) do
      remove :uploader_id
    end
  end
end
