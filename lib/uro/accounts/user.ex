defmodule Uro.Accounts.User do
  @moduledoc """
  The User schema.
  """

  use Ecto.Schema

  @pow_config user_id_field: :email,
              password_hash_verify: {&Bcrypt.hash_pwd_salt/1, &Bcrypt.verify_pass/2}

  def pow_config(), do: @pow_config

  use Pow.Ecto.Schema, @pow_config

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword]

  use PowAssent.Ecto.Schema

  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset
  import Uro.Helpers.Changeset

  alias Uro.Accounts.User.JSONSchema
  alias Uro.Accounts.User.Status

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}

  @derive {Jason.Encoder,
           only: [
             :id,
             :username,
             :display_name,
             :icon,
             :banner,
             :biography,
             :status,
             :status_message,
             :email,
             :email_confirmed_at,
             :email_notifications,
             :user_privilege_ruleset,
             :created_at
           ]}

  schema "users" do
    field(:username, :string)
    field(:display_name, :string)

    field(:icon, :string)
    field(:banner, :string)

    field(:biography, :string, default: "")

    field(:status, Ecto.Enum,
      values: Status.values(),
      default: :offline
    )

    field(:status_message, :string)

    field(:email, :string)
    field(:email_confirmed_at, :utc_datetime)
    field(:email_notifications, :boolean)

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

    timestamps(inserted_at: :created_at)
  end

  defmodule JSONSchema do
    @moduledoc """
    JSON Schema for the User schema.
    """
    use Uro.JSONSchema, []

    alias Uro.Accounts.User.Status
    alias Uro.Accounts.UserPrivilegeRuleset

    OpenApiSpex.schema(%{
      title: "User",
      type: :object,
      required: [
        :id,
        :username,
        :display_name,
        :icon,
        :banner,
        :biography,
        :status,
        :status_message,
        :email,
        :email_confirmed_at,
        :email_notifications,
        :user_privilege_ruleset,
        :created_at
      ],
      properties: %{
        id: %Schema{
          title: "UserID",
          type: :string,
          format: :uuid
        },
        username: %Schema{
          title: "Username",
          type: :string,
          minLength: 3,
          maxLength: 16
        },
        display_name: %Schema{
          type: :string
        },
        icon: %Schema{
          type: :string,
          nullable: true
        },
        banner: %Schema{
          type: :string,
          nullable: true
        },
        biography: %Schema{
          type: :string
        },
        status: Status,
        status_message: %Schema{
          type: :string,
          nullable: true
        },
        email: %Schema{
          type: :string,
          format: :email
        },
        email_confirmed_at: %Schema{
          type: :string,
          format: :"date-time",
          nullable: true
        },
        email_notifications: %Schema{
          type: :boolean
        },
        user_privilege_ruleset: UserPrivilegeRuleset.JSONSchema,
        created_at: %Schema{
          type: :string,
          format: :"date-time"
        }
      }
    })
  end

  defmodule LooseKey do
    @moduledoc """
    A loose representation of a user, can any of the following:

    * The literal `@me` string, representing the current user,
    * A user's username,
    * Or their ID.
    """

    require OpenApiSpex
    alias OpenApiSpex.Schema
    alias Uro.Accounts.User

    OpenApiSpex.schema(%{
      title: "LooseUserKey",
      description: @moduledoc,
      default: "@me",
      oneOf: [
        %Schema{
          title: "@me",
          type: :string,
          enum: ["@me"]
        },
        User.JSONSchema.shape(:id),
        User.JSONSchema.shape(:username)
      ]
    })
  end

  def admin?(%{user_privilege_ruleset: %{is_admin: is_admin}}), do: is_admin
  def admin?(_), do: false

  @spec lock_changeset(Schema.t() | Changeset.t()) :: Changeset.t()
  def lock_changeset(user_or_changeset) do
    changeset = change(user_or_changeset)
    locked_at = DateTime.truncate(DateTime.utc_now(), :second)

    case get_field(changeset, :locked_at) do
      nil -> change(changeset, locked_at: locked_at)
      _any -> add_error(changeset, :locked_at, "already set")
    end
  end

  def unlock_changeset(user_or_changeset) do
    changeset = change(user_or_changeset)

    case get_field(changeset, :locked_at) do
      nil -> add_error(changeset, :locked_at, "already set")
      _any -> change(changeset, locked_at: nil)
    end
  end

  defmodule UpdateJSONSchema do
    @moduledoc false

    use Uro.JSONSchema, []
    alias Uro.Accounts.User.JSONSchema

    OpenApiSpex.schema(%{
      title: "UserUpdate",
      type: :object,
      properties: %{
        display_name: JSONSchema.shape(:display_name),
        username: JSONSchema.shape(:username),
        biography: JSONSchema.shape(:biography),
        email_notifications: JSONSchema.shape(:email_notifications),
        status_message: JSONSchema.shape(:status_message)
      }
    })
  end

  def user_custom_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [
      :display_name,
      :username,
      :biography,
      :email_notifications,
      :status_message
    ])
    |> validate_required([:display_name, :username])
    |> validate_display_name(:display_name)
    |> validate_username(:username)
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
      :icon,
      get_field(changeset, :icon) || userinfo["picture"]
    )
  end

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
    |> cast(%{email: email}, [:email])
    |> validate_different(:email)
    |> validate_email(:email)
    |> put_change(:email_confirmed_at, nil)
  end

  def update_email_changeset(changeset, email, send_confirmation: false) do
    changeset
    |> cast(%{email: email}, [:email])
    |> validate_different(:email)
    |> validate_email(:email)
    |> confirm_email_changeset()
  end

  def validate_current_password(changeset, %{password_hash: password_hash}) do
    if(password_hash == nil, do: changeset, else: validate_required(changeset, :current_password))
    |> validate_change(:current_password, fn _, current_password ->
      Pow.Ecto.Schema.Changeset.verify_password(
        %{password_hash: password_hash},
        current_password,
        pow_config()
      )
      |> case do
        true -> []
        false -> [{:current_password, "is invalid"}]
      end
    end)
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
