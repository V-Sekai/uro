defmodule Uro.UserRelationsTest do
  use Uro.DataCase

  alias Uro.UserRelations

  describe "friendships" do
    alias Uro.UserRelations.Friendship

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def friendship_fixture(attrs \\ %{}) do
      {:ok, friendship} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserRelations.create_friendship()

      friendship
    end

    test "list_friendships/0 returns all friendships" do
      friendship = friendship_fixture()
      assert UserRelations.list_friendships() == [friendship]
    end

    test "get_friendship!/1 returns the friendship with given id" do
      friendship = friendship_fixture()
      assert UserRelations.get_friendship!(friendship.id) == friendship
    end

    test "create_friendship/1 with valid data creates a friendship" do
      assert {:ok, %Friendship{} = friendship} = UserRelations.create_friendship(@valid_attrs)
    end

    test "create_friendship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRelations.create_friendship(@invalid_attrs)
    end

    test "update_friendship/2 with valid data updates the friendship" do
      friendship = friendship_fixture()
      assert {:ok, %Friendship{} = friendship} = UserRelations.update_friendship(friendship, @update_attrs)
    end

    test "update_friendship/2 with invalid data returns error changeset" do
      friendship = friendship_fixture()
      assert {:error, %Ecto.Changeset{}} = UserRelations.update_friendship(friendship, @invalid_attrs)
      assert friendship == UserRelations.get_friendship!(friendship.id)
    end

    test "delete_friendship/1 deletes the friendship" do
      friendship = friendship_fixture()
      assert {:ok, %Friendship{}} = UserRelations.delete_friendship(friendship)
      assert_raise Ecto.NoResultsError, fn -> UserRelations.get_friendship!(friendship.id) end
    end

    test "change_friendship/1 returns a friendship changeset" do
      friendship = friendship_fixture()
      assert %Ecto.Changeset{} = UserRelations.change_friendship(friendship)
    end
  end
end
