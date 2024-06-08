defmodule UroWeb.Helpers.API do
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [json: 2]

  @default_security [%{"cookie" => []}, %{"bearer" => []}]

  @spec default_security() :: [map()]
  def default_security(), do: @default_security

  defmodule ErrorObject do
    @moduledoc false

    require OpenApiSpex
    alias OpenApiSpex.Schema

    OpenApiSpex.schema(%{
      title: "Error",
      type: :object,
      required: [:status, :message],
      properties: %{
        status: %Schema{
          type: :integer,
          example: 400
        },
        message: %Schema{
          type: :string,
          example: "Bad request"
        }
      }
    })
  end

  def json_error(conn, message \\ "Bad request.", options \\ []) do
    status = Keyword.get(options, :status, 400)

    conn
    |> put_status(status)
    |> json(%{status: status, message: message})
  end

  @doc false
  defmacro __using__(_config) do
    quote do
      import unquote(__MODULE__)
    end
  end
end
