defmodule UroWeb.Admin.OpsController do
  alias Uro.Ops
  use UroWeb, :controller

  def index(conn, _params) do
    changeset = Ops.get_ops_options() |> Ops.changeset(%{})
    render(conn, "index.html", changeset: changeset)
  end

  def update(conn, %{"ops" => ops}) do
    case Ops.get_ops_options()
         |> Ops.update_ops(ops) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Ops settings changed"))
        |> redirect(to: Routes.admin_ops_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Error making ops changes"))
        |> redirect(to: Routes.admin_ops_path(conn, :index))
    end
  end
end
