defmodule UroWeb.AvatarControllerTest do
  use UroWeb.ConnCase

  alias Uro.Content

  @create_attrs %{description: "some description", name: "some name", url: "some url"}
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    url: "some updated url"
  }
  @invalid_attrs %{description: nil, name: nil, url: nil}

  def fixture(:avatar) do
    {:ok, avatar} = Content.create_avatar(@create_attrs)
    avatar
  end

  describe "index" do
    test "lists all avatars", %{conn: conn} do
      conn = get(conn, Routes.admin_avatar_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Avatars"
    end
  end

  describe "new avatar" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_avatar_path(conn, :new))
      assert html_response(conn, 200) =~ "New Avatar"
    end
  end

  describe "create avatar" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_avatar_path(conn, :create), avatar: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_avatar_path(conn, :show, id)

      conn = get(conn, Routes.admin_avatar_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Avatar"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_avatar_path(conn, :create), avatar: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Avatar"
    end
  end

  describe "edit avatar" do
    setup [:create_avatar]

    test "renders form for editing chosen avatar", %{conn: conn, avatar: avatar} do
      conn = get(conn, Routes.admin_avatar_path(conn, :edit, avatar))
      assert html_response(conn, 200) =~ "Edit Avatar"
    end
  end

  describe "update avatar" do
    setup [:create_avatar]

    test "redirects when data is valid", %{conn: conn, avatar: avatar} do
      conn = put(conn, Routes.admin_avatar_path(conn, :update, avatar), avatar: @update_attrs)
      assert redirected_to(conn) == Routes.admin_avatar_path(conn, :show, avatar)

      conn = get(conn, Routes.admin_avatar_path(conn, :show, avatar))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, avatar: avatar} do
      conn = put(conn, Routes.admin_avatar_path(conn, :update, avatar), avatar: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Avatar"
    end
  end

  describe "delete avatar" do
    setup [:create_avatar]

    test "deletes chosen avatar", %{conn: conn, avatar: avatar} do
      conn = delete(conn, Routes.admin_avatar_path(conn, :delete, avatar))
      assert redirected_to(conn) == Routes.admin_avatar_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_avatar_path(conn, :show, avatar))
      end
    end
  end

  defp create_avatar(_) do
    avatar = fixture(:avatar)
    {:ok, avatar: avatar}
  end
end
