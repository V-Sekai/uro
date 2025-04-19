import Config
require Logger

Code.require_file("config/helpers.exs")
Code.ensure_loaded!(Uro.Config.Helpers)
alias Uro.Config.Helpers

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

config :uro,
  compile_phase?: System.get_env("COMPILE_PHASE") != "false"

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
		--config=tailwind.config.js
		--input=css/app.css
		--output=../priv/static/assets/app.css
	    ),
	    cd: Path.expand("../assets", __DIR__)
       ]

url =
  "URL"
  |> get_env.("https://vsekai.local/api/v1/")
  |> URI.new!()

root_origin =
  "ROOT_ORIGIN"
  |> get_env.("https://vsekai.local")
  |> URI.new!()

config :uro,
  ecto_repos: [Uro.Repo],
  url: url,
  frontend_url:
    "FRONTEND_URL"
    |> Helpers.get_env("https://vsekai.local/")
    |> URI.new!(),
  root_origin: root_origin

config :uro, Uro.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: Helpers.get_env("DATABASE_URL", "postgresql://vsekai:vsekai@database:5432/vsekai"),
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "uro-dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  migration_lock: false

config :uro, Redix, url: Helpers.get_env("REDIS_URL", "redis://redis:6379")

config :uro, Uro.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: System.get_env("PHX_HOST") || [host: "localhost"],
  http: [
    port:
      "PORT"
      |> Helpers.get_env("4000")
      |> String.to_integer()
  ],
  secret_key_base:
    Helpers.get_env(
      "PHOENIX_KEY_BASE",
      "bNDe+pg86uL938fQA8QGYCJ4V7fE5RAxoQ8grq9drPpO7mZ0oEMSNapKLiA48smR"
    ),
  pubsub_server: Uro.PubSub,
  live_view: [signing_salt: "0dBPUwA2"],
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:uro, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:uro, ~w(--watch)]}
  ]

config :cors_plug,
  origin: [URI.to_string(root_origin)],
  max_age: 86400

config :joken, default_signer: Helpers.get_env("JOKEN_SIGNER", "gqawCOER09ZZjaN8W2QM9XT9BeJSZ9qc")

config :uro, :stale_shard_cutoff,
  amount: 3,
  calendar_type: "month"

config :uro, :stale_shard_interval, 30 * 24 * 60 * 60 * 1000

config :uro, Uro.Turnstile,
  secret_key:
    get_optional_env.("TURNSTILE_SECRET_KEY") ||
      Logger.warning(
        "Turnstile (a reCaptcha alternative) is disabled because the environment variable TURNSTILE_SECRET_KEY is not set. For more information, see https://developers.cloudflare.com/turnstile/get-started/."
      )

config :uro, :pow,
  user: Uro.Accounts.User,
  users_context: Uro.Accounts,
  repo: Uro.Repo,
  web_module: Uro,
  extensions: [PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  routes_backend: Uro.Pow.Routes,
  cache_store_backend: Uro.Pow.RedisCache

config :uro, :pow_assent,
  user_identities_context: Uro.UserIdentities,
  providers:
    (case(compile_phase?) do
       true ->
         []

       false ->
         System.get_env()
         |> Map.filter(fn {k, _} -> String.match?(k, ~r/^OAUTH2_.+_STRATEGY/) end)
         |> Enum.map(fn {key, module_name} ->
           key =
             key
             |> String.replace("OAUTH2_", "")
             |> String.replace("_STRATEGY", "")

           {
             key
             |> String.downcase()
             |> String.to_atom(),
             [
               client_id: get_env.("OAUTH2_#{key}_CLIENT_ID", nil),
               client_secret: get_env.("OAUTH2_#{key}_CLIENT_SECRET", nil),
               strategy: Module.concat([module_name])
             ]
           }
         end)
     end)

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
