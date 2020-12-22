defmodule Uro.Repo.Migrations.AddMissingUserAssociations do
  use Ecto.Migration

  def up do
    Enum.each Uro.Accounts.list_users_admin, fn user ->
      user
      |> Uro.Repo.preload([:user_privilege_ruleset])
      |> case do
        nil -> Uro.Accounts.create_user_privilege_ruleset_for_user(user, %{is_admin: user.is_admin})
        _ -> nil
      end
      user
      |> Uro.Repo.preload([:upload_set])
      |> case do
        nil -> Uro.Accounts.create_upload_set_for_user(user)
        _ -> nil
      end
    end
  end

  def down do
    Uro.Repo.delete_all(Uro.Accounts.UserPrivilegeRuleset)
    Uro.Repo.delete_all(Uro.UserContent.UploadSet)
  end
end
