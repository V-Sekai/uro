import Config

config :uro, Uro.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :uro, Uro.Mailer, adapter: Swoosh.Adapters.Local

config :open_api_spex, :cache_adapter, OpenApiSpex.Plug.NoneCache

config :logger, :console, format: "[$level] $message\n"
config :logger, level: :debug

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :uro, Uro.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  url: System.get_env("DATABASE_URL"),
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "uro-dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :joken, default_signer: "gqawCOER09ZZjaN8W2QM9XT9BeJSZ9qc"

config :uro, Uro.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  http: [port: "4000"],
  check_origin: false,
  debug_errors: true,
  secret_key_base: "bNDe+pg86uL938fQA8QGYCJ4V7fE5RAxoQ8grq9drPpO7mZ0oEMSNapKLiA48smR"
