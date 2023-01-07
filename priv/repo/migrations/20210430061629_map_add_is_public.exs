defmodule Uro.Repo.Migrations.MapAddIsPublic do
  use Ecto.Migration

  def change do
    alter table(:maps) do
      add :is_public, :boolean, default: false, null: false
    end
  end
end
