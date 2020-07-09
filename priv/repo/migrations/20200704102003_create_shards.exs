defmodule Uro.Repo.Migrations.CreateShards do
  use Ecto.Migration

  def change do
    create table(:shards) do
      add :host, :string
      add :map, :string

      add :max_users, :integer

      timestamps()
    end

  end
end
