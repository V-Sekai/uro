import Config

# Configure your database
config :vertex, Vertex.Repo,
  adapter: Ecto.Adapaters.Postgres,
  username: "root",
  password: "",
  port: "26257",
  database: "vertex_test",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vertex, VertexWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
