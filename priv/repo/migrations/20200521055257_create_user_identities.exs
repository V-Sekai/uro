defmodule Uro.Repo.Migrations.CreateUserIdentities do
  use Ecto.Migration

  def change do
    create table(:user_identities, primary_key: false, options: "STRICT, WITHOUT ROWID") do
      add :id, :uuid, primary_key: true
      add :provider, :string, null: false
      add :uid, :string, null: false
      add :user_id, references("users", on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create unique_index(:user_identities, [:uid, :provider])
  end
end
