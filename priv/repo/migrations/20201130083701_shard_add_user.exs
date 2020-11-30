defmodule Uro.Repo.Migrations.ShardAddUser do
  use Ecto.Migration

  def change do
    alter table(:shards) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
    end
  end
end
