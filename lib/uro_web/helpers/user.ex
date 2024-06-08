defmodule UroWeb.Helpers.User do
  @moduledoc false

  defmodule UserObject do
    @moduledoc false

    require OpenApiSpex
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "User",
      type: :object,
      required: [:id, :username, :display_name],
      properties: %{
        id: %Schema{
          type: :string
        },
        username: %Schema{
          type: :string
        },
        display_name: %Schema{
          type: :string
        },
        avatar: %Schema{
          type: :string
        }
      }
    })
  end

  def transform_user(user) when is_map(user) do
    %{
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      avatar: user.profile_picture
    }
  end

  def transform_user(users) when is_list(users),
    do: Enum.map(users, fn x -> transform_user(x) end)

  def transform_user(_), do: nil
end
