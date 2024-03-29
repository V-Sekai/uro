defmodule Uro.Repo.Migrations.AvatarAddIsPublic do
  use Ecto.Migration

  def change do
    alter table(:avatars) do
      add :is_public, :boolean, default: false, null: false
    end
  end
end
