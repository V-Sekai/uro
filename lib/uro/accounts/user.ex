defmodule Uro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt

  schema "users" do
    field :email, :string
    field :username, :string
    field :hashed_password, :string

    # Do not store in database
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> validate_length(:password, min: 6)
    |> validate_length(:username, max: 128)
    |> validate_format(:email, ~r/(.*?)\@\w+\.\w+/)
    |> downcase_email
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
  end

  defp put_pass_hash(changeset), do: changeset

  def downcase_email(%{valid?: true, changes: %{email: email}}=changeset) do
    put_change(changeset, :email, email |> String.downcase)
  end

  def downcase_email(changeset), do: changeset
end
