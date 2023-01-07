defmodule Uro.Repo.Migrations.PropAddIsPublic do
  use Ecto.Migration

  def change do
    alter table(:props) do
      add :is_public, :boolean, default: false, null: false
    end
  end
end
