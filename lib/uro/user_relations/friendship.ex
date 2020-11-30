defmodule Uro.UserRelations.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friendships" do
    belongs_to :from_user, Accounts.User, foreign_key: :from_user_id
    belongs_to :to_user, Accounts.User, foreign_key: :to_user_id
    timestamps()
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [])
    |> validate_required([])
  end
end
