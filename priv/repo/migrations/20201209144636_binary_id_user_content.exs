defmodule Uro.Repo.Migrations.BinaryIdUserContent do
  use Ecto.Migration

  def change do
    create table(:avatars, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :description, :text
      add :url, :string
      add :uploader_id, references(:users, type: :uuid)

      timestamps()
    end

    create table(:maps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :description, :text
      add :url, :string
      add :uploader_id, references(:users, type: :uuid)

      timestamps()
    end

    create table(:props, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :description, :text
      add :url, :string
      add :uploader_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
