defmodule UroWeb.ResetPasswordController do
  use UroWeb, :controller

  alias PowResetPassword.{Phoenix.ResetPasswordController, Plug, Store.ResetTokenCache}

  def create(conn, params) do
    conn
    |> ResetPasswordController.process_create(params)
    |> maybe_halt()
    |> ResetPasswordController.respond_create()
  end

  defp maybe_halt({:ok, %{token: token, user: %{locked_at: locked_at}}, conn})
       when not is_nil(locked_at) do
    user = Plug.change_user(conn)

    expire_token(conn, token)

    {:error, %{user | action: :update}, conn}
  end

  defp maybe_halt(response), do: response

  defp expire_token(conn, token) do
    config = Pow.Plug.fetch_config(conn)

    case Pow.Plug.verify_token(conn, Atom.to_string(PowResetPassword.Plug), token, config) do
      {:ok, token} ->
        backend = Pow.Config.get(config, :cache_store_backend, Pow.Store.Backend.EtsCache)

        ResetTokenCache.delete([backend: backend], token)

      :error ->
        :ok
    end
  end
end
