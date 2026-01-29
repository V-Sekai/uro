defmodule Uro.QA.Support.QACase do
  @moduledoc """
  Shared test setup for QA tests.
  Creates a test user with upload permissions.
  """

  use ExUnit.CaseTemplate

  alias Uro.Accounts.{User, UserPrivilegeRuleset}
  alias Uro.Repo

  using do
    quote do
      use Uro.RepoCase

      import Plug.Test
      import Phoenix.ConnTest

      alias Uro.Endpoint
    end
  end

  setup do
    # Create QA test user with upload permissions
    current_time = DateTime.utc_now()

    user =
      %User{}
      |> User.admin_changeset(%{
        email: "qa_user@example.com",
        username: "qauser",
        display_name: "QA Test User",
        email_notifications: false,
        password: "qapassword",
        password_confirmation: "qapassword",
        email_confirmed_at: current_time
      })
      |> User.confirm_email_changeset()
      |> Repo.insert!()

    %UserPrivilegeRuleset{}
    |> UserPrivilegeRuleset.admin_changeset(%{
      user_id: user.id,
      is_admin: false,
      can_upload_avatars: true,
      can_upload_maps: true,
      can_upload_props: false,
      can_upload_shared_files: false
    })
    |> Repo.insert!()

    # Preload user with ruleset
    user = Repo.preload(user, :user_privilege_ruleset)

    {:ok, user: user, qa_password: "qapassword"}
  end
end
