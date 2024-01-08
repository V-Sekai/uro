defmodule UroWeb.PropControllerTest do
  use UroWeb.ConnCase

  alias Uro.UserContent

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:prop) do
    {:ok, prop} = UserContent.create_prop(@create_attrs)
    prop
  end

  describe "index" do
    test "lists all props", %{conn: conn} do
      conn = get(conn, Routes.admin_prop_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Props"
    end
  end

  describe "new prop" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_prop_path(conn, :new))
      assert html_response(conn, 200) =~ "New Prop"
    end
  end

  describe "create prop" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_prop_path(conn, :create), prop: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_prop_path(conn, :show, id)

      conn = get(conn, Routes.admin_prop_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Prop"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_prop_path(conn, :create), prop: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Prop"
    end
  end

  describe "edit prop" do
    setup [:create_prop]

    test "renders form for editing chosen prop", %{conn: conn, prop: prop} do
      conn = get(conn, Routes.admin_prop_path(conn, :edit, prop))
      assert html_response(conn, 200) =~ "Edit Prop"
    end
  end

  describe "update prop" do
    setup [:create_prop]

    test "redirects when data is valid", %{conn: conn, prop: prop} do
      conn = put(conn, Routes.admin_prop_path(conn, :update, prop), prop: @update_attrs)
      assert redirected_to(conn) == Routes.admin_prop_path(conn, :show, prop)

      conn = get(conn, Routes.admin_prop_path(conn, :show, prop))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, prop: prop} do
      conn = put(conn, Routes.admin_prop_path(conn, :update, prop), prop: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Prop"
    end
  end

  describe "delete prop" do
    setup [:create_prop]

    test "deletes chosen prop", %{conn: conn, prop: prop} do
      conn = delete(conn, Routes.admin_prop_path(conn, :delete, prop))
      assert redirected_to(conn) == Routes.admin_prop_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_prop_path(conn, :show, prop))
      end
    end
  end

  defp create_prop(_) do
    prop = fixture(:prop)
    {:ok, prop: prop}
  end
end
