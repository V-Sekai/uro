defmodule Uro.Repo.Migrations.FriendshipKeys do
  use Ecto.Migration

  def change do
    alter table(:friendships) do
      remove :user_id
      remove :friend_id

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :friend_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
    end

    create unique_index(:friendships, [:user_id, :friend_id])
  end
end
