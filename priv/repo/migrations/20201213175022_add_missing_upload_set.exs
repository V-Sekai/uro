defmodule Uro.Repo.Migrations.AddMissingUploadSet do
  use Ecto.Migration

  def up do
    Enum.each Uro.Accounts.list_users, fn user ->
      user
      |> Uro.Repo.preload([:upload_set])
      Uro.Accounts.create_upload_set_for_user(user)
    end
  end

  def down do
    Uro.Repo.delete_all(Uro.UserContent.UploadSet)
  end
end
