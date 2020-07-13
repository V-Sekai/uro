defmodule Uro.VSekai.Shard do
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
    |> validate_host(:address)
  end

  @doc false
  def validate_host(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn (_current_field, value) ->
      if Uro.VSekai.get_shard_by_address(value) do
        [{field, " is already used!"}]
      else
        []
      end
    end)
  end
end
