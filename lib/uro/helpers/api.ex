defmodule Uro.Helpers.API do
  @moduledoc """
  API helper functions.
  """

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

    conn
    |> put_status(code)
    |> json(
      Enum.into(options, %{
        message: Keyword.get(options, :message, Plug.Conn.Status.reason_phrase(code)),
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
