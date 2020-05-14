defmodule Uro.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :username, :string
      add :password_hash, :string

      add :display_name, :string

      timestamps()
    end

    create unique_index(:users, :username)
    create unique_index(:users, :email)
  end
end
