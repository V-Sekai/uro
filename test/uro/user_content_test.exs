defmodule Uro.ContentTest do
  use Uro.DataCase

  alias Uro.UserContent

  describe "avatars" do
    alias Uro.UserContent.Avatar

    @valid_attrs %{description: "some description", name: "some name", url: "some url"}
    @update_attrs %{description: "some updated description", name: "some updated name", url: "some updated url"}
    @invalid_attrs %{description: nil, name: nil, url: nil}

    def avatar_fixture(attrs \\ %{}) do
      {:ok, avatar} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserContent.create_avatar()

      avatar
    end

    test "list_avatars/0 returns all avatars" do
      avatar = avatar_fixture()
      assert UserContent.list_avatars() == [avatar]
    end

    test "get_avatar!/1 returns the avatar with given id" do
      avatar = avatar_fixture()
      assert UserContent.get_avatar!(avatar.id) == avatar
    end

    test "create_avatar/1 with valid data creates a avatar" do
      assert {:ok, %Avatar{} = avatar} = UserContent.create_avatar(@valid_attrs)
      assert avatar.description == "some description"
      assert avatar.name == "some name"
      assert avatar.url == "some url"
    end

    test "create_avatar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserContent.create_avatar(@invalid_attrs)
    end

    test "update_avatar/2 with valid data updates the avatar" do
      avatar = avatar_fixture()
      assert {:ok, %Avatar{} = avatar} = UserContent.update_avatar(avatar, @update_attrs)
      assert avatar.description == "some updated description"
      assert avatar.name == "some updated name"
      assert avatar.url == "some updated url"
    end

    test "update_avatar/2 with invalid data returns error changeset" do
      avatar = avatar_fixture()
      assert {:error, %Ecto.Changeset{}} = UserContent.update_avatar(avatar, @invalid_attrs)
      assert avatar == UserContent.get_avatar!(avatar.id)
    end

    test "delete_avatar/1 deletes the avatar" do
      avatar = avatar_fixture()
      assert {:ok, %Avatar{}} = UserContent.delete_avatar(avatar)
      assert_raise Ecto.NoResultsError, fn -> UserContent.get_avatar!(avatar.id) end
    end

    test "change_avatar/1 returns a avatar changeset" do
      avatar = avatar_fixture()
      assert %Ecto.Changeset{} = UserContent.change_avatar(avatar)
    end
  end

  describe "maps" do
    alias Uro.UserContent.Map

    @valid_attrs %{description: "some description", name: "some name", url: "some url"}
    @update_attrs %{description: "some updated description", name: "some updated name", url: "some updated url"}
    @invalid_attrs %{description: nil, name: nil, url: nil}

    def map_fixture(attrs \\ %{}) do
      {:ok, map} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserContent.create_map()

      map
    end

    test "list_maps/0 returns all maps" do
      map = map_fixture()
      assert UserContent.list_maps() == [map]
    end

    test "get_map!/1 returns the map with given id" do
      map = map_fixture()
      assert UserContent.get_map!(map.id) == map
    end

    test "create_map/1 with valid data creates a map" do
      assert {:ok, %Map{} = map} = UserContent.create_map(@valid_attrs)
      assert map.description == "some description"
      assert map.name == "some name"
      assert map.url == "some url"
    end

    test "create_map/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserContent.create_map(@invalid_attrs)
    end

    test "update_map/2 with valid data updates the map" do
      map = map_fixture()
      assert {:ok, %Map{} = map} = UserContent.update_map(map, @update_attrs)
      assert map.description == "some updated description"
      assert map.name == "some updated name"
      assert map.url == "some updated url"
    end

    test "update_map/2 with invalid data returns error changeset" do
      map = map_fixture()
      assert {:error, %Ecto.Changeset{}} = UserContent.update_map(map, @invalid_attrs)
      assert map == UserContent.get_map!(map.id)
    end

    test "delete_map/1 deletes the map" do
      map = map_fixture()
      assert {:ok, %Map{}} = UserContent.delete_map(map)
      assert_raise Ecto.NoResultsError, fn -> UserContent.get_map!(map.id) end
    end

    test "change_map/1 returns a map changeset" do
      map = map_fixture()
      assert %Ecto.Changeset{} = UserContent.change_map(map)
    end
  end

  describe "props" do
    alias Uro.UserContent.Prop

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def prop_fixture(attrs \\ %{}) do
      {:ok, prop} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserContent.create_prop()

      prop
    end

    test "list_props/0 returns all props" do
      prop = prop_fixture()
      assert UserContent.list_props() == [prop]
    end

    test "get_prop!/1 returns the prop with given id" do
      prop = prop_fixture()
      assert UserContent.get_prop!(prop.id) == prop
    end

    test "create_prop/1 with valid data creates a prop" do
      assert {:ok, %Prop{} = prop} = UserContent.create_prop(@valid_attrs)
    end

    test "create_prop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserContent.create_prop(@invalid_attrs)
    end

    test "update_prop/2 with valid data updates the prop" do
      prop = prop_fixture()
      assert {:ok, %Prop{} = prop} = UserContent.update_prop(prop, @update_attrs)
    end

    test "update_prop/2 with invalid data returns error changeset" do
      prop = prop_fixture()
      assert {:error, %Ecto.Changeset{}} = UserContent.update_prop(prop, @invalid_attrs)
      assert prop == UserContent.get_prop!(prop.id)
    end

    test "delete_prop/1 deletes the prop" do
      prop = prop_fixture()
      assert {:ok, %Prop{}} = UserContent.delete_prop(prop)
      assert_raise Ecto.NoResultsError, fn -> UserContent.get_prop!(prop.id) end
    end

    test "change_prop/1 returns a prop changeset" do
      prop = prop_fixture()
      assert %Ecto.Changeset{} = UserContent.change_prop(prop)
    end
  end
end
