defmodule Uro.UserContent do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Uro.Repo

  alias Uro.UserContent.Avatar

  @doc """
  Returns the list of avatars.

  ## Examples

      iex> list_avatars()
      [%Avatar{}, ...]

  """
  def list_avatars do
    Avatar
    |> Repo.all
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Gets a single avatar.

  Raises `Ecto.NoResultsError` if the Avatar does not exist.

  ## Examples

      iex> get_avatar!(123)
      %Avatar{}

      iex> get_avatar!(456)
      ** (Ecto.NoResultsError)

  """
  def get_avatar!(id) do
    Avatar
    |> Repo.get!(id)
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Creates a avatar.

  ## Examples

      iex> create_avatar(%{field: value})
      {:ok, %Avatar{}}

      iex> create_avatar(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_avatar(attrs \\ %{}) do
    %Avatar{}
    |> Avatar.changeset(attrs)
    |> Repo.insert()
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Updates a avatar.

  ## Examples

      iex> update_avatar(avatar, %{field: new_value})
      {:ok, %Avatar{}}

      iex> update_avatar(avatar, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_avatar(%Avatar{} = avatar, attrs) do
    avatar
    |> Avatar.changeset(attrs)
    |> Repo.update()
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Deletes a avatar.

  ## Examples

      iex> delete_avatar(avatar)
      {:ok, %Avatar{}}

      iex> delete_avatar(avatar)
      {:error, %Ecto.Changeset{}}

  """
  def delete_avatar(%Avatar{} = avatar) do
    Repo.delete(avatar)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking avatar changes.

  ## Examples

      iex> change_avatar(avatar)
      %Ecto.Changeset{source: %Avatar{}}

  """
  def change_avatar(%Avatar{} = avatar) do
    Avatar.changeset(avatar, %{})
  end

  alias Uro.UserContent.Map

  @doc """
  Returns the list of maps.

  ## Examples

      iex> list_maps()
      [%Map{}, ...]

  """
  def list_maps do
    Map
    |> Repo.all
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Gets a single map.

  Raises `Ecto.NoResultsError` if the Map does not exist.

  ## Examples

      iex> get_map!(123)
      %Map{}

      iex> get_map!(456)
      ** (Ecto.NoResultsError)

  """
  def get_map!(id) do
    Map
    |> Repo.get!(id)
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Creates a map.

  ## Examples

      iex> create_map(%{field: value})
      {:ok, %Map{}}

      iex> create_map(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_map(attrs \\ %{}) do
    %Map{}
    |> Map.changeset(attrs)
    |> Repo.insert()
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Updates a map.

  ## Examples

      iex> update_map(map, %{field: new_value})
      {:ok, %Map{}}

      iex> update_map(map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_map(%Map{} = map, attrs) do
    map
    |> Map.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a map.

  ## Examples

      iex> delete_map(map)
      {:ok, %Map{}}

      iex> delete_map(map)
      {:error, %Ecto.Changeset{}}

  """
  def delete_map(%Map{} = map) do
    Repo.delete(map)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking map changes.

  ## Examples

      iex> change_map(map)
      %Ecto.Changeset{source: %Map{}}

  """
  def change_map(%Map{} = map) do
    Map.changeset(map, %{})
  end

  alias Uro.UserContent.Prop

  @doc """
  Returns the list of props.

  ## Examples

      iex> list_props()
      [%Prop{}, ...]

  """
  def list_props do
    Prop
    |> Repo.all
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Gets a single prop.

  Raises `Ecto.NoResultsError` if the Prop does not exist.

  ## Examples

      iex> get_prop!(123)
      %Prop{}

      iex> get_prop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prop!(id) do
    Prop
    |> Repo.get!(id)
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Creates a prop.

  ## Examples

      iex> create_prop(%{field: value})
      {:ok, %Prop{}}

      iex> create_prop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prop(attrs \\ %{}) do
    %Prop{}
    |> Prop.changeset(attrs)
    |> Repo.insert()
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Updates a prop.

  ## Examples

      iex> update_prop(prop, %{field: new_value})
      {:ok, %Prop{}}

      iex> update_prop(prop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prop(%Prop{} = prop, attrs) do
    prop
    |> Prop.changeset(attrs)
    |> Repo.update()
    |> Repo.preload(uploader: [:uploader])
  end

  @doc """
  Deletes a prop.

  ## Examples

      iex> delete_prop(prop)
      {:ok, %Prop{}}

      iex> delete_prop(prop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prop(%Prop{} = prop) do
    Repo.delete(prop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prop changes.

  ## Examples

      iex> change_prop(prop)
      %Ecto.Changeset{source: %Prop{}}

  """
  def change_prop(%Prop{} = prop) do
    Prop.changeset(prop, %{})
  end
end
