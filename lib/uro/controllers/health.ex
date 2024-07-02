defmodule Uro.HealthController do
  use Uro, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  tags(["system"])

  operation(:index,
    operation_id: "health",
    summary: "Health",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{
          type: :object,
          properties: %{
            services: %Schema{
              type: :object,
              properties: %{
                uro: %Schema{type: :string}
              }
            }
          }
        }
      }
    ]
  )

  def index(conn, _params) do
    json(conn, %{services: %{uro: "ok"}})
  end
end
