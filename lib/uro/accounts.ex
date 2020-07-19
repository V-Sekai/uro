defmodule Uro.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Uro.Repo

  alias Uro.Accounts.User

  def get_by_username(username) when is_nil(username) do
    nil
  end
  def get_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def get_by_email(email) when is_nil(email) do
    nil
  end
  def get_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_by_username_or_email(username_or_email) when is_nil(username_or_email) do
    nil
  end
  def get_by_username_or_email(username_or_email) do
    User
    |> where(username: ^username_or_email)
    |> or_where(email: ^username_or_email)
    |> Repo.one
  end

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_admin(attrs \\ %{}) do
    %User{}
    |> User.changeset_admin(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_admin(%User{} = user, attrs) do
    user
    |> User.changeset_admin(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
