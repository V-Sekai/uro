defmodule UroWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use UroWeb, :controller
  use UroWeb.Helpers.API

  alias Ecto.Changeset
  alias UroWeb.ErrorHelpers

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    properties = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

    json_error(
      conn,
      "Unprocessable Entity",
      status: :unprocessable_entity,
      properties: properties
    )
  end
end
