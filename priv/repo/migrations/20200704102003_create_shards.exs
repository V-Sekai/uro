defmodule Uro.Repo.Migrations.CreateShards do
  use Ecto.Migration

  def change do
    create table(:shards, primary_key: false, options: "STRICT, WITHOUT ROWID") do
      add :id, :uuid, primary_key: true
      add :address, :string
      add :port, :integer
      add :name, :string

      add :current_users, :integer
      add :max_users, :integer

      timestamps()
    end
  end
end
