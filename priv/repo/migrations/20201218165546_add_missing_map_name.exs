defmodule Uro.Repo.Migrations.AddMissingMapName do
  use Ecto.Migration

  def change do
    alter table(:maps) do
      add :name, :string
    end
  end
end
