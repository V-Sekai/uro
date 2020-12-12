defmodule Uro.VSekai.Shard do
  @derive {Jason.Encoder, only: [:user, :address, :port, :map, :name, :current_users, :max_users]}
  use Ecto.Schema
  import Ecto.Changeset

  schema "shards" do
    belongs_to :user, Uro.Accounts.User, foreign_key: :user_id, type: :binary_id

    field :address, :string
    field :port, :integer
    field :map, :string
    field :name, :string

    field :current_users, :integer, default: 0
    field :max_users, :integer, default: 32

    timestamps()
  end

  @doc false
  def changeset(shard, attrs) do
    shard
    |> cast(attrs, [:user_id, :address, :port, :map, :name, :current_users, :max_users])
    |> validate_required([:address, :port, :map, :name])
  end
end
