defmodule :"Elixir.Uro.Repo.Migrations." do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :unconfirmed_email
      remove :email_confirmation_token
    end
  end
end
