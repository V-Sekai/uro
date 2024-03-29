defmodule Uro.Repo.Migrations.CreateUploaderIds do
  use Ecto.Migration

  def change do
    alter table(:avatars) do
      add :uploader_id, references(:users, type: :uuid)
    end

    alter table(:maps) do
      add :uploader_id, references(:users, type: :uuid)
    end

    alter table(:props) do
      add :uploader_id, references(:users, type: :uuid)
    end
  end
end
