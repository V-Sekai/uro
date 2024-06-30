defmodule Uro.Repo.Migrations.AddBannerAndBiography do
  use Ecto.Migration

  def change do
    rename table(:users), :profile_picture, to: :icon
    rename table(:users), :inserted_at, to: :created_at

    alter table(:users) do
      add :banner, :string
      add :biography, :string
      add :status, :string
      add :status_message, :string
    end
  end
end
