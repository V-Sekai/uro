import Config
require Logger

compile_phase? = System.get_env("COMPILE_PHASE") != "false"

get_env = fn key, example ->
  case compile_phase? do
    true ->
      example

    false ->
      System.get_env(key) ||
        raise """
        Environment variable "#{key}" is required but not set.
        """
  end
end

get_optional_env = fn key ->
  System.get_env(key)
end

config :uro, Uro.Repo, migration_lock: false

config :uro,
  compile_phase?: System.get_env("COMPILE_PHASE") != "false"

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :uro, Uro.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  http: [port: "4000"]

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
