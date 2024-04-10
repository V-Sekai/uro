defmodule Uro.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false, options: "STRICT, WITHOUT ROWID") do
      add :id, :uuid, primary_key: true
      add :description, :string
      add :name, :string

      add :start_date, :utc_datetime
      add :end_date, :utc_datetime

      timestamps()
    end
  end
end
