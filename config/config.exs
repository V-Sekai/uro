# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :vertex,
  title: "Vertex",
  ecto_repos: [Vertex.Repo]

# Configures the endpoint
config :vertex, VertexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bNDe+pg86uL938fQA8QGYCJ4V7fE5RAxoQ8grq9drPpO7mZ0oEMSNapKLiA48smR",
  render_errors: [view: VertexWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Vertex.PubSub,
  live_view: [signing_salt: "0dBPUwA2"]

config :vertex, VertexWeb.Pow.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY", "")

config :vertex, :stale_shard_cutoff,
  amount: 3,
  calendar_type: "month"

# every 30 days
config :vertex, :stale_shard_interval, 30 * 24 * 60 * 60 * 1000

config :email_checker,
  default_dns: :system,
  also_dns: [],
  validations: [EmailChecker.Check.Format],
  smtp_retries: 2,
  timeout_milliseconds: :infinity

config :vertex, :pow,
  user: Vertex.Accounts.User,
  repo: Vertex.Repo,
  web_module: VertexWeb,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: VertexWeb.Pow.Mailer,
  routes_backend: VertexWeb.Pow.Routes,
  web_mailer_module: VertexWeb,
  cache_store_backend: Pow.Store.Backend.MnesiaCache

config :vertex, :pow_assent,
  user_identities_context: Vertex.UserIdentities,
  providers: []

config :vertex, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: VertexWeb.Router,
      endpoint: VertexWeb.Endpoint
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
