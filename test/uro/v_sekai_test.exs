defmodule Uro.VSekaiTest do
  use Uro.DataCase

  alias Uro.VSekai

  describe "shards" do
    alias Uro.VSekai.Shard

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def shard_fixture(attrs \\ %{}) do
      {:ok, shard} =
        attrs
        |> Enum.into(@valid_attrs)
        |> VSekai.create_shard()

      shard
    end

    test "list_shards/0 returns all shards" do
      shard = shard_fixture()
      assert VSekai.list_shards() == [shard]
    end

    test "get_shard!/1 returns the shard with given id" do
      shard = shard_fixture()
      assert VSekai.get_shard!(shard.id) == shard
    end

    test "create_shard/1 with valid data creates a shard" do
      assert {:ok, %Shard{} = shard} = VSekai.create_shard(@valid_attrs)
    end

    test "create_shard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VSekai.create_shard(@invalid_attrs)
    end

    test "update_shard/2 with valid data updates the shard" do
      shard = shard_fixture()
      assert {:ok, %Shard{} = shard} = VSekai.update_shard(shard, @update_attrs)
    end

    test "update_shard/2 with invalid data returns error changeset" do
      shard = shard_fixture()
      assert {:error, %Ecto.Changeset{}} = VSekai.update_shard(shard, @invalid_attrs)
      assert shard == VSekai.get_shard!(shard.id)
    end

    test "delete_shard/1 deletes the shard" do
      shard = shard_fixture()
      assert {:ok, %Shard{}} = VSekai.delete_shard(shard)
      assert_raise Ecto.NoResultsError, fn -> VSekai.get_shard!(shard.id) end
    end

    test "change_shard/1 returns a shard changeset" do
      shard = shard_fixture()
      assert %Ecto.Changeset{} = VSekai.change_shard(shard)
    end
  end
end
