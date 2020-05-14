defmodule Uro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import EmailChecker
  import Burnex

  schema "users" do
    field :email, :string
    field :username, :string
    field :password_hash, :string

    field :display_name, :string

    # Do not store in database
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> validate_length(:password, min: 8)
    |> validate_length(:username, max: 128)
    |> validate_email(:email)
    |> put_display_name
    |> downcase_email
    |> downcase_username
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash
  end

  def validate_email(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn (current_field, value) ->
      if !EmailChecker.valid?(value) do
        [{field, " is not valid!"}]
      else
        []
      end
    end)
  end

  defp put_display_name(%Ecto.Changeset{valid?: true, changes: %{username: username}} = changeset) do
    put_change(changeset, :display_name, username)
  end

  defp put_display_name(changeset), do: changeset

  def downcase_username(%{valid?: true, changes: %{username: username}}=changeset) do
    put_change(changeset, :username, username |> String.downcase)
  end

  def downcase_username(changeset), do: changeset

  def downcase_email(%{valid?: true, changes: %{email: email}}=changeset) do
    put_change(changeset, :email, email |> String.downcase)
  end

  def downcase_email(changeset), do: changeset

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
