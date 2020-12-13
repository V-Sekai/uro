defmodule Uro.Repo.Migrations.CreateUploadSet do
  use Ecto.Migration

  def change do
    create table(:upload_set, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:upload_set, [:user_id])
  end
end
