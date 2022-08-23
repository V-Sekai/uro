defmodule Uro.Repo.Migrations.CreateOps do
  use Ecto.Migration

  def change do
    create table(:ops) do
      add :maint_mode, :boolean, default: false, null: false

      timestamps()
    end

  end
end
