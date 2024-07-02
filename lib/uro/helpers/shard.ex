defmodule Uro.Helpers.Shard do
  @moduledoc false

  defmodule SchemaShard do
    @moduledoc false

    require OpenApiSpex

    alias OpenApiSpex.Schema
    alias Uro.Accounts.User

    OpenApiSpex.schema(%{
      title: "Shard",
      type: :object,
      required: [:id, :username, :display_name],
      properties: %{
        user: User.JSONSchema,
        address: %Schema{
          type: :string
        },
        port: %Schema{
          type: :integer
        },
        map: %Schema{
          type: :string
        },
        name: %Schema{
          type: :string
        },
        current_users: %Schema{
          type: :integer
        },
        max_users: %Schema{
          type: :integer
        }
      }
    })
  end

  def transform_shard(shard) when is_map(shard) do
    %{
      user: shard.user,
      address: to_string(shard.address),
      port: shard.port,
      map: to_string(shard.map),
      name: to_string(shard.name),
      current_users: shard.current_users,
      max_users: shard.max_users
    }
  end

  def transform_shard(shard) when is_list(shard),
    do: Enum.map(shard, fn x -> transform_shard(x) end)

  def transform_shard(_), do: nil
end
