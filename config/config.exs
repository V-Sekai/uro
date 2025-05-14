import Config
require Logger

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :esbuild,
  version: "0.25.0",
  uro: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "4.0.9",
  uro: [
    args: ~w(
		--input=css/app.css
		--output=../priv/static/assets/app.css
	    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :uro,
  ecto_repos: [Uro.Repo]

config :uro, Uro.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "postgresql://vsekai:vsekai@database:5432/vsekai",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "uro-dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  migration_lock: false

config :uro, Redix, url: System.get_env("REDIS_URL") || "redis://redis:6379"

config :uro, Uro.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  pubsub_server: Uro.PubSub,
  render_errors: [
    formats: [html: UroWeb.ErrorHTML, json: UroWeb.ErrorJSON],
    layout: false
  ],
  live_view: [signing_salt: "0dBPUwA2"]

config :joken, default_signer: "gqawCOER09ZZjaN8W2QM9XT9BeJSZ9qc"

config :uro, :stale_shard_cutoff,
  amount: 3,
  calendar_type: "month"

config :uro, :stale_shard_interval, 30 * 24 * 60 * 60 * 1000

config :uro, :pow,
  user: Uro.Accounts.User,
  users_context: Uro.Accounts,
  repo: Uro.Repo,
  web_module: Uro,
  extensions: [PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  routes_backend: Uro.Pow.Routes,
  cache_store_backend: Uro.Pow.RedisCache

config :uro, :pow_assent, user_identities_context: Uro.UserIdentities

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :waffle,
  storage: Waffle.Storage.Local

# storage_dir: "uploads"

import_config "#{Mix.env()}.exs"

if Mix.env() == "dev" do
  import_config "local.exs"
end
