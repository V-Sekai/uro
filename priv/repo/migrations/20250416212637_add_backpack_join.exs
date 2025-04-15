defmodule Uro.Repo.Migrations.AddBackpackJoin do
  use Ecto.Migration

  def change do
    create table(:backpack_join, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :owner_id, references(:users, type: :uuid)

      add :map_id, references(:maps, type: :uuid)
      add :avatar_id, references(:avatars, type: :uuid)
      add :prop_id, references(:props, type: :uuid)
      timestamps()
    end
  end
end
