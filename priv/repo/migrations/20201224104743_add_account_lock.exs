defmodule Uro.Repo.Migrations.AddAccountLock do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :locked_at, :utc_datetime
    end
  end
end
