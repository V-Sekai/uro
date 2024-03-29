defmodule Uro.Repo.Migrations.ShardSchemaAddMapField do
  use Ecto.Migration

  def change do
    alter table(:shards) do
      add :map, :string
    end
  end
end
