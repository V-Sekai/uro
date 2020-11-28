defmodule UroWeb.Admin.PropController do
  use UroWeb, :controller

  alias Uro.UserContent
  alias Uro.UserContent.Prop

  def index(conn, _params) do
    props = UserContent.list_props()
    render(conn, "index.html", props: props)
  end

  def new(conn, _params) do
    changeset = UserContent.change_prop(%Prop{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"prop" => prop_params}) do
    case UserContent.create_prop(prop_params) do
      {:ok, prop} ->
        conn
        |> put_flash(:info, gettext("Prop created successfully."))
        |> redirect(to: Routes.admin_prop_path(conn, :show, prop))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    prop = UserContent.get_prop!(id)
    render(conn, "show.html", prop: prop)
  end

  def edit(conn, %{"id" => id}) do
    prop = UserContent.get_prop!(id)
    changeset = UserContent.change_prop(prop)
    render(conn, "edit.html", prop: prop, changeset: changeset)
  end

  def update(conn, %{"id" => id, "prop" => prop_params}) do
    prop = UserContent.get_prop!(id)

    case UserContent.update_prop(prop, prop_params) do
      {:ok, prop} ->
        conn
        |> put_flash(:info, gettext("Prop updated successfully."))
        |> redirect(to: Routes.admin_prop_path(conn, :show, prop))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", prop: prop, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    prop = UserContent.get_prop!(id)
    {:ok, _prop} = UserContent.delete_prop(prop)

    conn
    |> put_flash(:info, gettext("Prop deleted successfully."))
    |> redirect(to: Routes.admin_prop_path(conn, :index))
  end
end
