defmodule Uro.UserRelations.Friendship do
  @moduledoc """
  A friendship between two users.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias OpenApiSpex.Schema
  alias Uro.Accounts.User
  alias Uro.Repo
  alias Uro.UserRelations.Friendship

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}

  @derive {Jason.Encoder,
           only: [
             :status,
             :accepted_at
           ]}

  schema "friendships" do
    belongs_to(:user, User, foreign_key: :user_id)
    belongs_to(:friend, User, foreign_key: :friend_id)

    field(:status, :string, virtual: true)
    field(:accepted_at, :utc_datetime)

    timestamps()
  end

  @friend_status_json_schema %Schema{
    title: "FriendStatus",
    type: :string,
    enum: [
      :none,
      :received,
      :sent,
      :accepted
    ]
  }

  def friend_status_json_schema, do: @friend_status_json_schema

  @json_schema %Schema{
    title: "Friendship",
    type: :object,
    required: [
      :status,
      :accepted_at
    ],
    properties: %{
      status: %Schema{
        type: :string,
        enum: [:accepted]
      },
      accepted_at: %Schema{
        format: "date-time",
        type: :string,
        nullable: true
      }
    }
  }

  def json_schema, do: @json_schema

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:user_id, :friend_id, :accepted_at])
    |> validate_required([:user_id, :friend_id])
    |> unique_constraint([:user_id, :friend_id],
      error_key: :friend_id
    )
  end

  defp associations(%User{id: self_id}, %User{id: friend_id}) do
    {
      Repo.get_by(Friendship, user_id: self_id, friend_id: friend_id),
      Repo.get_by(Friendship, user_id: friend_id, friend_id: self_id)
    }
  end

  # You can never be friends with yourself.
  def friend_status(%User{id: self_id}, %User{id: self_id}), do: :none

  def friend_status(%User{} = self, %User{} = friend) do
    {a, b} = associations(self, friend)
    friend_status(a, b)
  end

  def friend_status(nil, nil), do: :none
  def friend_status(nil, _), do: :received
  def friend_status(_, nil), do: :sent
  def friend_status(_, _), do: :accepted

  def get_friendship(%User{} = self, %User{} = friend) do
    {a, b} = associations(self, friend)
    Map.put(a || %Friendship{}, :status, friend_status(a, b))
  end

  def add_friend(self, friend) do
    Repo.transaction(fn ->
      case friend_status(self, friend) do
        :none ->
          %Friendship{}
          |> changeset(%{user_id: self.id, friend_id: friend.id})
          |> Repo.insert!()

          :sent

        :received ->
          accepted_at = DateTime.truncate(DateTime.utc_now(), :second)

          %Friendship{}
          |> changeset(%{user_id: self.id, friend_id: friend.id, accepted_at: accepted_at})
          |> Repo.insert!()

          {1, nil} =
            Friendship
            |> where([f], f.user_id == ^friend.id and f.friend_id == ^self.id)
            |> Repo.update_all(set: [accepted_at: accepted_at])

          :accepted

        :sent ->
          Repo.rollback(:already_sent)

        :accepted ->
          Repo.rollback(:already_friends)
      end
    end)
  end

  def remove_friend(self, friend) do
    Repo.transaction(fn ->
      case friend_status(self, friend) do
        :accepted ->
          {1, nil} =
            Friendship
            |> where([f], f.user_id == ^self.id and f.friend_id == ^friend.id)
            |> Repo.delete_all()

          :unfriended

        :sent ->
          {1, nil} =
            Friendship
            |> where([f], f.user_id == ^self.id and f.friend_id == ^friend.id)
            |> Repo.delete_all()

          :revoked_request

        _ ->
          Repo.rollback(:not_friends)
      end
    end)
  end
end
