defmodule UroWeb.Helpers.API do
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [json: 2]

  @default_security [%{"cookie" => []}, %{"bearer" => []}]

  @spec default_security() :: [map()]
  def default_security(), do: @default_security

  defmodule SchemaError do
    @moduledoc """
    A representation of an error response.
    """

    require OpenApiSpex
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "Error",
      type: :object,
      required: [:message, :status],
      properties: %{
        message: %Schema{
          type: :string,
          description: "A human-readable message describing the error.",
          example: "Bad request."
        },
        status: %Schema{
          type: :integer,
          example: 400
        },
        properties: %Schema{
          type: :object,
          description: "Property specific errors, in response to invalid requests.",
          example: %{
            username: ["should be at least 3 character(s)"],
            password: ["was already taken"]
          },
          additionalProperties: %Schema{
            type: :array,
            items: %Schema{
              type: :string
            }
          }
        }
      }
    })
  end

  def json_error(conn, message \\ "Bad request.", options \\ []) do
    status = Keyword.get(options, :status, :bad_request)

    conn
    |> put_status(status)
    |> json(
      options
      |> Enum.into(%{})
      |> Map.merge(%{
        message: message,
        status: Plug.Conn.Status.code(status)
      })
    )
  end

  @doc false
  defmacro __using__(_config) do
    quote do
      import unquote(__MODULE__)
    end
  end
end
