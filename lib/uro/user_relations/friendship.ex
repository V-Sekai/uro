defmodule Uro.UserRelations.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}
  schema "friendships" do
    belongs_to :user, Accounts.User, foreign_key: :user_id
    belongs_to :friend, Accounts.User, foreign_key: :friend_id
    timestamps()
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [])
    |> validate_required([])
  end
end
