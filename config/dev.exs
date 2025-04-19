import Config
Code.require_file("config/helpers.exs")
Code.ensure_loaded!(Uro.Config.Helpers)
alias Uro.Config.Helpers

config :uro, Uro.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  secret_key_base: "3+5khBafQZMJZn54zonDHfgjFwXl7fYugKy1R7md/4zVyuXDt8OpqCd/GIdpOKxm",
  http: [ip: {0, 0, 0, 0}, port: 4000],
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:uro, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:uro, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/uro_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

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
  username: "vsekai",
  password: "vsekai",
  hostname: "localhost",
  port: 26257,
  database: "uro-dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  migration_lock: false

redis_url = Helpers.get_env("REDIS_URL", nil)
config :uro, Redix, url: if(redis_url, do: redis_url, else: "redis://localhost:6379")
