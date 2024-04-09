defmodule Uro.Repo.Migrations.CreateUserPrivileges do
  use Ecto.Migration

  def change do
    create table(:user_privilege_rulesets, primary_key: false, options: "STRICT, WITHOUT ROWID") do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      add :is_admin, :boolean, default: false, null: false
      add :can_upload_avatars, :boolean, default: false, null: false
      add :can_upload_maps, :boolean, default: false, null: false
      add :can_upload_props, :boolean, default: false, null: false

      timestamps()
    end
  end
end
