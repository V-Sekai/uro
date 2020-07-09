defmodule Uro.VSekai do
  @moduledoc """
  The VSekai context.
  """

  import Ecto.Query, warn: false
  alias Uro.Repo

  alias Uro.VSekai.Shard

  @doc """
  Returns the list of shards.

  ## Examples

      iex> list_shards()
      [%Shard{}, ...]

  """
  def list_shards do
    Repo.all(Shard)
  end

  @doc """
  Gets a single shard.

  Raises `Ecto.NoResultsError` if the Shard does not exist.

  ## Examples

      iex> get_shard!(123)
      %Shard{}

      iex> get_shard!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shard!(id), do: Repo.get!(Shard, id)

  @doc """
  Creates a shard.

  ## Examples

      iex> create_shard(%{field: value})
      {:ok, %Shard{}}

      iex> create_shard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shard(attrs \\ %{}) do
    %Shard{}
    |> Shard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shard.

  ## Examples

      iex> update_shard(shard, %{field: new_value})
      {:ok, %Shard{}}

      iex> update_shard(shard, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shard(%Shard{} = shard, attrs) do
    shard
    |> Shard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shard.

  ## Examples

      iex> delete_shard(shard)
      {:ok, %Shard{}}

      iex> delete_shard(shard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shard(%Shard{} = shard) do
    Repo.delete(shard)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shard changes.

  ## Examples

      iex> change_shard(shard)
      %Ecto.Changeset{source: %Shard{}}

  """
  def change_shard(%Shard{} = shard) do
    Shard.changeset(shard, %{})
  end
end
