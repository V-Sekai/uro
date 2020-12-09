defmodule Uro.Repo.Migrations.DropUserContent do
  use Ecto.Migration

  def change do
    drop table(:avatars)
    drop table(:maps)
    drop table(:props)
  end
end
