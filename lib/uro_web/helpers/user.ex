defmodule UroWeb.Helpers.User do
  @moduledoc """
  User helper functions.
  """

  import Uro.Helpers.UUID

  alias Uro.Accounts
  alias Uro.Plug.Authentication

  def resolve_user_from_id(conn, id_or_username) do
    current_user = Authentication.current_user(conn)

    case id_or_username do
      "@me" ->
        current_user

      _
      when id_or_username == current_user.id or
             id_or_username == current_user.username ->
        current_user

      _
      when is_uuid(id_or_username) ->
        Accounts.get_user!(id_or_username)

      _ ->
        Accounts.get_by_username(id_or_username)
    end
  end
end
