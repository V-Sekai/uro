# lib/my_app_web/ensure_user_not_locked_plug.ex
defmodule Uro.EnsureUserNotLockedPlug do
  alias Pow.Config
  alias Pow.Plug, as: PowPlug

  @doc false
  @spec init(Config.t()) :: atom()
  def init(config) do
    Config.get(config, :error_handler) || raise_no_error_handler!()
  end

  @doc false
  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, handler) do
    conn
    |> PowPlug.current_user()
    |> locked?()
    |> maybe_halt(conn, handler)
  end

  defp locked?(%{locked_at: locked_at}) when not is_nil(locked_at), do: true
  defp locked?(_user), do: false

  defp maybe_halt(true, conn, handler) do
    conn
    |> PowPlug.delete()
    |> handler.call(:account_locked)
    |> Plug.Conn.halt()
  end

  defp maybe_halt(_any, conn, _handler), do: conn

  @spec raise_no_error_handler!() :: no_return()
  defp raise_no_error_handler!,
    do:
      Config.raise_error(
        "No :error_handler configuration option provided. It's required to set this when using #{inspect(__MODULE__)}."
      )
end
