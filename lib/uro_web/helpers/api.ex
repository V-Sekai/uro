defmodule UroWeb.Helpers.API do
  use UroWeb, :controller

  @doc false
  def json_error(conn, status) do
    conn
    |> put_status(status)
    |> json(%{errors: ""})
  end

  @doc false
  defmacro __using__(_config) do
    quote do
      import unquote(__MODULE__), only: [json_error: 2]
    end
  end
end
