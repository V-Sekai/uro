defmodule Uro.Repo.Migrations.DropFriendships do
  use Ecto.Migration

  def change do
    drop table(:friendships)
  end
end
