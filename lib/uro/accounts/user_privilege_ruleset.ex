defmodule Uro.Accounts.UserPrivilegeRuleset do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:is_admin, :can_upload_avatars, :can_upload_maps, :can_upload_props]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}
  schema "user_privilege_rulesets" do
    belongs_to :user, Uro.Accounts.User, foreign_key: :user_id, type: :binary_id

    field :is_admin, :boolean, default: false
    field :can_upload_avatars, :boolean, default: false
    field :can_upload_maps, :boolean, default: false
    field :can_upload_props, :boolean, default: false

    timestamps()
  end

  def admin_changeset(user_privilege_ruleset_or_changeset, attrs) do
    user_privilege_ruleset_or_changeset
    |> cast(attrs, [:user_id, :is_admin, :can_upload_avatars, :can_upload_maps, :can_upload_props])
  end
end
