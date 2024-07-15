defmodule Uro.Repo.Migrations.FriendshipAcceptedAt do
  use Ecto.Migration

  def change do
    alter table(:friendships) do
      add :accepted_at, :utc_datetime
    end
  end
end
