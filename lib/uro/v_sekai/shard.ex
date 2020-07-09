defmodule Uro.VSekai.Shard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shards" do
    field :host, :string
    field :map, :string

    field :max_users, :integer

    timestamps()
  end

  @doc false
  def changeset(shard, attrs) do
    shard
    |> cast(attrs, [:host, :map, :max_users])
    |> validate_required([:host, :map, :max_users])
  end
end
