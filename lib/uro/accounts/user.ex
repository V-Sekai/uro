defmodule Uro.Accounts.User do
  use Ecto.Schema

  use Pow.Ecto.Schema,
    user_id_field: :email,
    password_hash_verify: {&Bcrypt.hash_pwd_salt/1, &Bcrypt.verify_pass/2}

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword]

  use PowAssent.Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}

  @derive {Jason.Encoder,
           [
             only: [
               :id,
               :username,
               :display_name,
               :profile_picture,
               :email,
               :email_confirmed_at,
               :email_notifications,
               :user_privilege_ruleset,
               :inserted_at
             ]
           ]}

  schema "users" do
    field(:username, :string)
    field(:display_name, :string)
    field(:email, :string)
    field(:email_confirmed_at, :utc_datetime)
    field(:email_notifications, :boolean)

    field(:profile_picture, :string)

    has_one(:user_privilege_ruleset, Uro.Accounts.UserPrivilegeRuleset, foreign_key: :user_id)

    has_many(:uploaded_avatars, Uro.UserContent.Avatar, foreign_key: :uploader_id)
    has_many(:uploaded_maps, Uro.UserContent.Map, foreign_key: :uploader_id)
    has_many(:uploaded_props, Uro.UserContent.Prop, foreign_key: :uploader_id)

    many_to_many(:friendships, Uro.UserRelations.Friendship,
      join_through: "friendships",
      join_keys: [user: :id, friend: :id]
    )

    has_many(:hosted_shards, Uro.VSekai.Shard, foreign_key: :user_id)

    has_many(:identity_proofs_from, Uro.UserRelations.IdentityProof, foreign_key: :user_from_id)
    has_many(:identity_proofs_to, Uro.UserRelations.IdentityProof, foreign_key: :user_to_id)

    field(:locked_at, :utc_datetime)

    pow_user_fields()

    timestamps()
  end

  defmodule IDSchema do
    @moduledoc false

    require OpenApiSpex
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "UserID",
      description: "The User ID. Use `@me` to get the current user.",
      type: :string,
      example: "b4cfd6bd-16fc-4485-a878-a52fce173177",
      default: "@me"
    })
  end

  defmodule Schema do
    @moduledoc false

    require OpenApiSpex
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "User",
      type: :object,
      required: [
        :id,
        :username,
        :display_name,
        :email,
        :email_confirmed_at,
        :avatar,
        :created_at
      ],
      properties: %{
        id: IDSchema,
        username: %Schema{
          type: :string
        },
        display_name: %Schema{
          type: :string
        },
        email: %Schema{
          type: :string,
          format: "email",
          nullable: true
        },
        email_confirmed_at: %Schema{
          type: :string,
          format: "date-time",
          nullable: true
        },
        avatar: %Schema{
          type: :string,
          nullable: true
        },
        created_at: %Schema{
          type: :string,
          format: "date-time"
        }
      }
    })
  end

  @spec lock_changeset(Schema.t() | Changeset.t()) :: Changeset.t()
  def lock_changeset(user_or_changeset) do
    changeset = change(user_or_changeset)
    locked_at = DateTime.truncate(DateTime.utc_now(), :second)

    case get_field(changeset, :locked_at) do
      nil -> change(changeset, locked_at: locked_at)
      _any -> add_error(changeset, :locked_at, "already set")
    end
  end

  @spec unlock_changeset(Schema.t() | Changeset.t()) :: Changeset.t()
  def unlock_changeset(user_or_changeset) do
    changeset = change(user_or_changeset)

    case get_field(changeset, :locked_at) do
      nil -> add_error(changeset, :locked_at, "already set")
      _any -> change(changeset, locked_at: nil)
    end
  end

  def user_custom_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:display_name, :username, :email, :password, :email_notifications])
    |> validate_required([:display_name, :username, :email, :password])
    |> validate_display_name(:display_name)
    |> validate_username(:username)
    |> validate_email(:email)
    |> unique_constraint(:username)
  end

  def changeset(user_or_changeset, attrs) do
    attrs =
      case attrs do
        %{"password" => password} ->
          # Asking the user to confirm their password is an antiqued practice, but Pow expects it.
          # https://estevanmaito.me/blog/killing-the-confirm-password-field-is-not-enough
          Map.put(attrs, "password_confirmation", password)

        _ ->
          attrs
      end

    user_or_changeset
    |> pow_changeset(attrs)
    # |> pow_extension_changeset(attrs)
    |> user_custom_changeset(attrs)
  end

  def user_identity_changeset(user_or_changeset, user_identity, attrs, user_id_attrs) do
    %{"userinfo" => userinfo} = user_identity

    changeset =
      pow_assent_user_identity_changeset(user_or_changeset, user_identity, attrs, user_id_attrs)

    username =
      get_field(changeset, :username) || attrs["username"] || userinfo["preferred_username"]

    unique_constraint(changeset, :username)
    |> put_change(:username, username)
    |> validate_username(:username)
    |> put_change(
      :display_name,
      get_field(changeset, :display_name) || userinfo["name"] || userinfo["preferred_username"] ||
        username
    )
    |> validate_display_name(:display_name)
    |> put_change(
      :profile_picture,
      get_field(changeset, :profile_picture) || userinfo["picture"]
    )
  end

  @spec admin_changeset(Schema.t() | Changeset.t(), Map) :: Changeset.t()
  def admin_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_user_id_field_changeset(attrs)
    |> pow_password_changeset(attrs)
    |> user_custom_changeset(attrs)
    |> cast(attrs, [:display_name])
  end

  def confirm_email_changeset(changeset) do
    change(
      changeset,
      %{
        email_confirmed_at: DateTime.truncate(DateTime.utc_now(), :second)
      }
    )
  end

  def update_email_changeset(changeset, email, send_confirmation: true) do
    changeset
    |> change(%{email: email, email_confirmed_at: nil})
    |> validate_email(:email)
  end

  def update_email_changeset(changeset, email, send_confirmation: false) do
    changeset
    |> change(%{email: email})
    |> validate_email(:email)
    |> confirm_email_changeset()
  end

  def validate_display_name(changeset, field) when is_atom(field) do
    validate_length(
      changeset,
      field,
      min: 3,
      max: 32
    )
  end

  def validate_username(changeset, field) when is_atom(field) do
    case Map.get(changeset.changes, field) do
      nil ->
        changeset

      username ->
        changeset
        |> put_change(field, String.downcase(username))
        |> validate_length(
          field,
          min: 3,
          max: 16
        )
        |> validate_format(
          field,
          ~r/^[a-z0-9_]+$/,
          message: "must contain only lowercase letters, numbers, and underscores"
        )
    end
  end

  def validate_email(changeset, field) when is_atom(field) do
    EctoCommons.EmailValidator.validate_email(changeset, field)
  end

  def admin_search(query, search_term) do
    wildcard_search = "%#{search_term}%"

    from(user in query,
      where: ilike(user.username, ^wildcard_search),
      or_where: ilike(user.display_name, ^wildcard_search),
      or_where: ilike(user.email, ^wildcard_search)
    )
  end
end
