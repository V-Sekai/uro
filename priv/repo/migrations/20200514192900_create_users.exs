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

      add :email_confirmation_token, :string
      add :email_confirmed_at, :utc_datetime
      add :unconfirmed_email, :string

      add :locked_at, :utc_datetime

      timestamps()
    end

    create unique_index(:users, :username)
    create unique_index(:users, :email)
    create unique_index(:users, :email_confirmation_token)
  end
end
