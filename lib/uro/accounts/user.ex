defmodule Uro.Accounts.User do
  use Ecto.Schema
  use Pow.Ecto.Schema,
    user_id_field: :email,
    password_hash_methods: {&Bcrypt.hash_pwd_salt/1, &Bcrypt.verify_pass/2}
  use PowAssent.Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}
  schema "users" do
    field :username, :string
    field :display_name, :string
    field :email_notifications, :boolean

    pow_user_fields()

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> cast(attrs, [:username, :email_notifications])
    |> put_display_name
    |> downcase_username
    |> validate_username(:username)
    |> validate_email(:email)
    |> unique_constraint(:username)
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
end
