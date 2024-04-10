# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :uro,
  title: "Uro",
  ecto_repos: [Uro.Repo]

# Configures the endpoint
config :uro, UroWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bNDe+pg86uL938fQA8QGYCJ4V7fE5RAxoQ8grq9drPpO7mZ0oEMSNapKLiA48smR",
  render_errors: [view: UroWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Uro.PubSub,
  live_view: [signing_salt: "0dBPUwA2"]

config :uro, UroWeb.Pow.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY", "")

config :uro, :stale_shard_cutoff,
  amount: 3,
  calendar_type: "month"

# every 30 days
config :uro, :stale_shard_interval, 30 * 24 * 60 * 60 * 1000

config :email_checker,
  default_dns: :system,
  also_dns: [],
  validations: [EmailChecker.Check.Format],
  smtp_retries: 2,
  timeout_milliseconds: :infinity

config :uro, :pow,
  user: Uro.Accounts.User,
  repo: Uro.Repo,
  web_module: UroWeb,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: UroWeb.Pow.Mailer,
  routes_backend: UroWeb.Pow.Routes,
  web_mailer_module: UroWeb,
  cache_store_backend: Pow.Store.Backend.MnesiaCache

config :uro, :pow_assent,
  user_identities_context: Uro.UserIdentities,
  providers: []

config :uro, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: UroWeb.Router,
      endpoint: UroWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :waffle,
  storage: Waffle.Storage.Local

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
