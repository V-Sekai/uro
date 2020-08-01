defmodule Uro.Repo.Migrations.ShardSchemaAddMapField do
  use Ecto.Migration

  def change do
    alter table(:shards) do
      add :name, :string
    end
  end

end
