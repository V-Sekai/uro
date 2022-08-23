defmodule Uro.Ops do
  use Ecto.Schema
  alias Uro.Repo
  import Ecto.Changeset

  schema "ops" do
    field :maint_mode, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(ops, attrs) do
    ops
    |> cast(attrs, [:maint_mode])
    |> validate_required([:maint_mode])
  end

  def get_ops_options() do
    result =
      __MODULE__
      |> Repo.one()

    if result == nil do
      {:ok, res} = Repo.insert(default_ops_options())
      res
    else
      result
    end
  end

  def update_ops(ops, params) do
    ops
    |> changeset(params)
    |> Repo.update()
  end

  defp default_ops_options() do
    defaults = %{
      maint_mode: false
    }

    %__MODULE__{}
    |> changeset(defaults)
  end
end
