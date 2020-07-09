defmodule Uro.Repo.Migrations.CreateProps do
  use Ecto.Migration

  def change do
    create table(:props) do
      add :name, :string
      add :description, :text
      add :url, :string

      timestamps()
    end

  end
end
