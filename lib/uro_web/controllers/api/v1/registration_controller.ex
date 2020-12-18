defmodule UroWeb.API.V1.RegistrationController do
  use UroWeb, :controller

  alias Ecto.Changeset
  alias Plug.Conn
  alias UroWeb.ErrorHelpers

  def show(conn, _params) do
    conn
    |> UroWeb.Helpers.Auth.get_current_user
    |> case do
      {:ok, user} ->
        conn
        |> UroWeb.Helpers.Auth.verify_confirmed_or_send_confirmation_email
        |> case do
          {:ok, conn} ->
            conn
            |> Pow.Plug.delete()
            |> json(%{data: %{user: user}})
          {:failed, conn} ->
            conn
            |> Pow.Plug.delete()
            |> json(%{data: %{user: user}})
        end
      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: gettext("Couldn't get current user")}})
    end
  end

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Uro.Accounts.create_user(user_params)
    |> case do
      {:ok, user, conn} ->
        json(conn, %{data: %{access_token: conn.private[:api_access_token], renewal_token: conn.private[:api_renewal_token], user: user}})

      {:error, changeset, conn} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: gettext("Couldn't create user"), errors: errors}})
    end
  end
end
