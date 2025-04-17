import Config

config :uro, Uro.Repo,
  show_sensitive_data_on_connection_error: true,
  url: System.get_env("TEST_DATABASE_URL"),
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "uro-test",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
