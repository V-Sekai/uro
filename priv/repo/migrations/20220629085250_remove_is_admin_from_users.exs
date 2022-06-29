defmodule Uro.Repo.Migrations.RemoveIsAdminFromUsers do
  use Ecto.Migration

  def down do
    alter table(:users) do
      add :is_admin, :boolean
    end
  end

  def up do
    alter table(:users) do
      remove :is_admin
    end
  end
end
