defmodule Uro.Repo.Migrations.CreateAvatars do
  use Ecto.Migration

  def change do
    create table(:avatars) do
      add :name, :string
      add :description, :text
      add :url, :string
      add :uploader_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
