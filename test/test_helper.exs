# Start the API application so router and endpoint are available
Application.ensure_all_started(:uro_api)

Ecto.Adapters.SQL.Sandbox.mode(Uro.Repo, :manual)
