defmodule UroWeb.Helpers.API do
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [json: 2]

  @default_security [%{"bearer" => []}, %{"cookie" => []}]

  @spec default_security() :: [map()]
  def default_security(), do: @default_security

  def json_error(conn, options \\ []) do
    code =
      options
      |> Keyword.get(:code, :bad_request)
      |> Plug.Conn.Status.code()

    message = Keyword.get(options, :message, Plug.Conn.Status.reason_phrase(code))

    conn
    |> put_status(code)
    |> json(
      options
      |> Enum.into(%{})
      |> Map.merge(%{
        message: message,
        code: Plug.Conn.Status.reason_atom(code)
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
