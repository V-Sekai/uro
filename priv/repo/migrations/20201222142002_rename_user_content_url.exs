defmodule Uro.Repo.Migrations.RenameUserContentUrl do
  use Ecto.Migration

  def change do
    rename table(:avatars), :url, to: :user_content_data
    rename table(:maps), :url, to: :user_content_data
    rename table(:props), :url, to: :user_content_data
  end
end
