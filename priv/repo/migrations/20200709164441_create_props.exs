defmodule Uro.Repo.Migrations.CreateProps do
  use Ecto.Migration

  def change do
    create table(:props, primary_key: false, options: "STRICT, WITHOUT ROWID") do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :description, :text
      add :url, :string
      add :uploader_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
