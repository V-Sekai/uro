defmodule UroWeb.ShardControllerTest do
  use UroWeb.ConnCase

  alias Uro.VSekai

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:shard) do
    {:ok, shard} = VSekai.create_shard(@create_attrs)
    shard
  end

  describe "index" do
    test "lists all shards", %{conn: conn} do
      conn = get(conn, Routes.admin_shard_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Shards"
    end
  end

  describe "new shard" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_shard_path(conn, :new))
      assert html_response(conn, 200) =~ "New Shard"
    end
  end

  describe "create shard" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_shard_path(conn, :create), shard: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_shard_path(conn, :show, id)

      conn = get(conn, Routes.admin_shard_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Shard"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_shard_path(conn, :create), shard: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shard"
    end
  end

  describe "edit shard" do
    setup [:create_shard]

    test "renders form for editing chosen shard", %{conn: conn, shard: shard} do
      conn = get(conn, Routes.admin_shard_path(conn, :edit, shard))
      assert html_response(conn, 200) =~ "Edit Shard"
    end
  end

  describe "update shard" do
    setup [:create_shard]

    test "redirects when data is valid", %{conn: conn, shard: shard} do
      conn = put(conn, Routes.admin_shard_path(conn, :update, shard), shard: @update_attrs)
      assert redirected_to(conn) == Routes.admin_shard_path(conn, :show, shard)

      conn = get(conn, Routes.admin_shard_path(conn, :show, shard))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, shard: shard} do
      conn = put(conn, Routes.admin_shard_path(conn, :update, shard), shard: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Shard"
    end
  end

  describe "delete shard" do
    setup [:create_shard]

    test "deletes chosen shard", %{conn: conn, shard: shard} do
      conn = delete(conn, Routes.admin_shard_path(conn, :delete, shard))
      assert redirected_to(conn) == Routes.admin_shard_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_shard_path(conn, :show, shard))
      end
    end
  end

  defp create_shard(_) do
    shard = fixture(:shard)
    {:ok, shard: shard}
  end
end
