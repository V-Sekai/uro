defmodule Uro.Repo.Migrations.AddUserContentPreviews do
  use Ecto.Migration

  def change do
    alter table(:avatars) do
      add :user_content_preview, :string
    end

    alter table(:maps) do
      add :user_content_preview, :string
    end

    alter table(:props) do
      add :user_content_preview, :string
    end
  end
end
