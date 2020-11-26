defmodule UroWeb.Helpers.Admin do
  use UroWeb, :controller

  @doc false
  def is_admin?(user) do
    user
    |> is_map
    |> case do
      true ->
        user
        |> Uro.Repo.preload([:user_privilege_ruleset])
        |> Map.get(:user_privilege_ruleset)
        |> check_admin_field
      false -> false
    end
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
