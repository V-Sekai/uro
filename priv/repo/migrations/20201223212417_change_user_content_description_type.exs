defmodule Uro.Repo.Migrations.ChangeUserContentDescriptionType do
  use Ecto.Migration

  def up do
    is_sqlite =
      Ecto.Adapter.lookup_meta(Uro.Repo.get_dynamic_repo()).sql ==
        Ecto.Adapters.SQLite3.Connection

    if not is_sqlite do
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
  end

  def down do
    is_sqlite =
      Ecto.Adapter.lookup_meta(Uro.Repo.get_dynamic_repo()).sql ==
        Ecto.Adapters.SQLite3.Connection

    if not is_sqlite do
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
end
