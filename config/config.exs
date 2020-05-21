# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :uro,
  ecto_repos: [Uro.Repo]

# Configures the endpoint
config :uro, UroWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bNDe+pg86uL938fQA8QGYCJ4V7fE5RAxoQ8grq9drPpO7mZ0oEMSNapKLiA48smR",
  render_errors: [view: UroWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Uro.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "0dBPUwA2"]

config :email_checker,
  default_dns: :system,
  also_dns: [],
  validations: [EmailChecker.Check.Format],
  smtp_retries: 2,
  timeout_milliseconds: :infinity

  config :uro, :pow,
  user: Uro.Accounts.User,
  repo: Uro.Repo,
  web_module: UroWeb

  config :uro, :pow_assent,
  providers: [
    google: [
      client_id: "REPLACE_WITH_CLIENT_ID",
      client_secret: "REPLACE_WITH_CLIENT_SECRET",
      strategy: Assent.Strategy.Google
    ]
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
