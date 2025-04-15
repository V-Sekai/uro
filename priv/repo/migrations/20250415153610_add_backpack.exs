defmodule Uro.Repo.Migrations.AddBackpack do
  use Ecto.Migration

  def change do
    create table(:backpacks, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :owner_id, references(:users, type: :uuid)
    end

    create table(:backpack_maps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :backpack_id, references(:backpacks, type: :uuid)
      add :map_id, references(:maps, type: :uuid)
    end

    create table(:backpack_avatars, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :backpack_id, references(:backpacks, type: :uuid)
      add :avatar_id, references(:avatars, type: :uuid)
    end

    create table(:backpack_props, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :backpack_id, references(:backpacks, type: :uuid)
      add :props_id, references(:props, type: :uuid)
    end
  end
end
