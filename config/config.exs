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
        Environment variable #{key} is required but not set.
        """
  end
end

get_optional_env = fn key ->
  System.get_env(key)
end

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

url =
  "URL"
  |> get_env.("https://example.com/api/")
  |> URI.new!()

root_origin =
  "ROOT_ORIGIN"
  |> get_env.("https://example.com")
  |> URI.new!()

config :uro,
  ecto_repos: [Uro.Repo],
  url: url,
  frontend_url:
    "FRONTEND_URL"
    |> get_env.("https://example.com/")
    |> URI.new!(),
  root_origin: root_origin

config :uro, Uro.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: get_env.("DATABASE_URL", nil)

config :uro, Redix, url: get_env.("REDIS_URL", nil)

config :uro, Uro.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: Map.take(url, [:scheme, :host, :path]),
  http: [
    port:
      "PORT"
      |> get_env.("4000")
      |> String.to_integer()
  ],
  secret_key_base: get_env.("PHOENIX_KEY_BASE", nil)

config :cors_plug,
  origin: [URI.to_string(root_origin)],
  max_age: 86400

config :joken, default_signer: get_env.("JOKEN_SIGNER", nil)

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

import_config "#{Mix.env()}.exs"
import_config "local.exs"
