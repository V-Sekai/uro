defmodule Uro.Plug.RequireAdmin do
  import Plug.Conn

  @doc false
  def init(options), do: options

  @doc false
  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, handler) do
    conn.assigns[:current_user]
    |> is_admin
    |> maybe_halt(conn, handler)
  end

  @doc false
  defp is_admin(%{is_admin: true}) do
    true
  end

  @doc false
  defp is_admin(_) do
    false
  end

  @doc false
  defp maybe_halt(true, conn, _handler), do: conn

  @doc false
  defp maybe_halt(false, conn, _handler) do
    conn
    |> put_status(403)
    |> send_resp(403, "Unauthorized 403")
    |> halt
  end
end
