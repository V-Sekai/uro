defmodule Uro.VSekai.Shard do
  @derive {Jason.Encoder, only: [:address, :port, :map, :current_users, :max_users]}
  use Ecto.Schema
  import Ecto.Changeset

  schema "shards" do
    field :address, :string
    field :port, :integer
    field :map, :string

    field :current_users, :integer, default: 0
    field :max_users, :integer, default: 32

    timestamps()
  end

  @doc false
  def changeset(shard, attrs) do
    shard
    |> cast(attrs, [:address, :port, :map, :current_users, :max_users])
    |> validate_required([:address, :port, :map])
  end
end
