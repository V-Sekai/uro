defmodule Uro.Repo.Migrations.ChangeUserContentDescriptionType do
  use Ecto.Migration

  def up do
    alter table(:avatars) do
      modify :description, :text
    end

    alter table(:maps) do
      modify :description, :text
    end

    alter table(:props) do
      modify :description, :text
    end
  end

  def down do
    alter table(:avatars) do
      modify :description, :string
    end

    alter table(:maps) do
      modify :description, :string
    end

    alter table(:props) do
      modify :description, :string
    end
  end
end
