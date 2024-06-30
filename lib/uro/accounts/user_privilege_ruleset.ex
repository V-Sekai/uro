defmodule Uro.Accounts.UserPrivilegeRuleset do
  @moduledoc false

  alias Uro.Accounts.User
  alias Uro.Repo

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :is_admin,
             :can_upload_avatars,
             :can_upload_maps,
             :can_upload_props
           ]}

  schema "user_privilege_rulesets" do
    belongs_to :user, Uro.Accounts.User, foreign_key: :user_id, type: :binary_id

    field :is_admin, :boolean, default: false
    field :can_upload_avatars, :boolean, default: false
    field :can_upload_maps, :boolean, default: false
    field :can_upload_props, :boolean, default: false

    timestamps()
  end

  defmodule JSONSchema do
    @moduledoc """
      A user's privilege ruleset, defining what they can do.
    """

    use Uro.JSONSchema
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "UserPrivilegeRuleset",
      description: @moduledoc,
      type: :object,
      required: [
        :is_admin,
        :can_upload_avatars,
        :can_upload_maps,
        :can_upload_props
      ],
      properties: %{
        is_admin: %Schema{type: :boolean},
        can_upload_avatars: %Schema{type: :boolean},
        can_upload_maps: %Schema{type: :boolean},
        can_upload_props: %Schema{type: :boolean}
      }
    })
  end

  def admin_changeset(user_privilege_ruleset_or_changeset, attrs) do
    cast(user_privilege_ruleset_or_changeset, attrs, [
      :user_id,
      :is_admin,
      :can_upload_avatars,
      :can_upload_maps,
      :can_upload_props
    ])
  end

  def associate(%User{} = user) do
    Repo.preload(user, :user_privilege_ruleset)
  end
end
