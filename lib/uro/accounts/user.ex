defmodule Uro.Accounts.User do
  @derive {Jason.Encoder, only: [:id, :username, :display_name]}
  use Ecto.Schema
  use Pow.Ecto.Schema,
    user_id_field: :email,
    password_hash_methods: {&Bcrypt.hash_pwd_salt/1, &Bcrypt.verify_pass/2}
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]
  use PowAssent.Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}
  schema "users" do
    field :username, :string
    field :display_name, :string
    field :email_notifications, :boolean

    field :profile_picture, :string
    field :is_admin, :boolean, default: false

    has_one :user_privilege_ruleset, Uro.Accounts.UserPrivilegeRuleset, foreign_key: :user_id

    has_many :uploaded_avatars, Uro.UserContent.Avatar, foreign_key: :uploader_id
    has_many :uploaded_maps, Uro.UserContent.Map, foreign_key: :uploader_id
    has_many :uploaded_props, Uro.UserContent.Prop, foreign_key: :uploader_id

    many_to_many :friendships, Uro.UserRelations.Friendship,
      join_through: "friendships",
      join_keys: [user: :id, friend: :id]

    has_many :hosted_shards, Uro.VSekai.Shard, foreign_key: :user_id

    has_many :identity_proofs_from, Uro.UserRelations.IdentityProof, foreign_key: :user_from_id
    has_many :identity_proofs_to, Uro.UserRelations.IdentityProof, foreign_key: :user_to_id

    pow_user_fields()

    timestamps()
  end

  def user_custom_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:username, :email_notifications])
    |> validate_required([:username])
    |> put_display_name
    |> downcase_username
    |> validate_username(:username)
    |> validate_email(:email)
    |> unique_constraint(:username)
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> user_custom_changeset(attrs)
  end

  defp put_display_name(%Ecto.Changeset{valid?: true, changes: %{username: username}} = changeset) do
    put_change(changeset, :display_name, username)
  end

  defp put_display_name(changeset), do: changeset

  def downcase_username(%{valid?: true, changes: %{username: username}}=changeset) do
    put_change(changeset, :username, username |> String.downcase)
  end

  def downcase_username(changeset), do: changeset

  def validate_username(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn (_current_field, value) ->
      if EmailChecker.valid?(value) or Uro.Accounts.get_by_email(value) do
        [{field, " is not valid!"}]
      else
        []
      end
    end)
  end

  def validate_email(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn (_current_field, value) ->
      if !EmailChecker.valid?(value) or Uro.Accounts.get_by_username(value) do
        [{field, " is not valid!"}]
      else
        []
      end
    end)
  end

  def admin_search(query, search_term) do
    wildcard_search = "%#{search_term}%"

    from user in query,
    where: ilike(user.username, ^wildcard_search),
    or_where: ilike(user.display_name, ^wildcard_search),
    or_where: ilike(user.email, ^wildcard_search)
  end
end
