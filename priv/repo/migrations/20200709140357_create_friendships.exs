defmodule Uro.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships, primary_key: false, options: "STRICT, WITHOUT ROWID") do
      add :id, :uuid, primary_key: true
      add :from_user_id, references(:users, type: :uuid)
      add :to_user_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
