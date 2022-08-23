defmodule UroWeb.MaintModePlug do
  alias Uro.Ops
  import Plug.Conn
  import Phoenix.Controller, only: [html: 2, json: 2]

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    maint_mode = Ops.get_ops_options().maint_mode

    cond do
      UroWeb.Helpers.Admin.is_session_admin?(conn) ->
        conn

      maint_mode ->
        conn
        |> reject(opts[:accepts])
        |> halt

      true ->
        conn
    end
  end

  defp reject(conn, :json) do
    conn
    |> json(%{message: "API is down for maintenance"})
  end

  defp reject(conn, :html) do
    conn
    |> html("<html><body>V-Sekai is down for maintenance</body></html>")
  end
end
