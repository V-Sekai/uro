defmodule Uro.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string

      add :username, :string
      add :display_name, :string

      add :email_notifications, :bool, default: false

      add :profile_picture, :string
      add :is_admin, :boolean

      timestamps()
    end

    create unique_index(:users, :username)
    create unique_index(:users, :email)
  end
end
