defmodule Uro.Repo.Migrations.DropUserIdentity do
  use Ecto.Migration

  def change do
    drop table(:user_identities)
  end
end
