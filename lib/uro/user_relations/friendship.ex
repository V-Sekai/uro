defmodule Uro.UserRelations.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friendships" do

    timestamps()
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [])
    |> validate_required([])
  end
end
