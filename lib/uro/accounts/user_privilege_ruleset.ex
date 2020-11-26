defmodule Uro.Accounts.UserPrivilegeRuleset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_privilege_rulesets" do
    belongs_to :user, Uro.Accounts.User, foreign_key: :user_id, type: :binary_id

    field :is_admin, :boolean, default: false
    field :can_upload_avatars, :boolean, default: false
    field :can_upload_maps, :boolean, default: false
    field :can_upload_props, :boolean, default: false

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [])
    |> validate_required([])
  end
end
