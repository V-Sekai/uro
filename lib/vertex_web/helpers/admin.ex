defmodule VertexWeb.Helpers.Admin do
  use VertexWeb, :controller

  @doc false
  def is_admin?(user) do
    user
    |> VertexWeb.Helpers.Auth.get_user_privilege_ruleset()
    |> check_admin_field
  end

  @doc false
  def is_session_admin?(conn) do
    conn.assigns[:current_user]
    |> is_admin?
  end

  @doc false
  defp check_admin_field(%{is_admin: true}) do
    true
  end

  @doc false
  defp check_admin_field(_) do
    false
  end
end
