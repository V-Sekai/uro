defmodule Uro.Helpers.User do
  @moduledoc """
  User helper functions.
  """

  import Uro.Helpers.UUID

  alias Uro.Accounts
  alias Uro.Accounts.User
  alias Uro.Plug.Authentication

  def user_from_key(conn, key) do
    current_user = Authentication.current_user(conn)

    case key do
      "@me" ->
        current_user

      _
      when key == current_user.id or
             key == current_user.username ->
        current_user

      _
      when is_uuid(key) ->
        Accounts.get_user!(key)

      _ ->
        Accounts.get_by_username(key)
    end
    |> case do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :not_found, "User not found"}
    end
  end

  def current_user(conn, optional: false) do
    case Authentication.current_user(conn) do
      %User{} = user -> {:ok, user}
      _ -> {:error, :invalid_credentials}
    end
  end

  def current_user(conn, optional: true) do
    case Authentication.current_user(conn) do
      %User{} = user -> {:ok, user}
      _ -> {:ok, nil}
    end
  end

  def current_user(conn), do: current_user(conn, optional: false)

  def user_confirmed_email(%User{email_confirmed_at: nil}),
    do: {:error, :forbidden, "Email not confirmed"}

  def user_confirmed_email(%User{} = user), do: {:ok, user}

  def validate_as_yourself(changeset, user, field_key \\ :user_id) do
    Ecto.Changeset.validate_inclusion(changeset, field_key, [user.id],
      message: "must be yourself"
    )
  end
end
