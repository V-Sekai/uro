import Config

# Unused (no static files)
# config :uro, Uro.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :uro, Uro.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY", "")

# Do not print debug messages in production.
config :logger, level: :info

url =
  "URL"
  |> get_env.("https://vsekai.local/api/v1/")
  |> URI.new!()

root_origin =
  "ROOT_ORIGIN"
  |> get_env.("https://vsekai.local")
  |> URI.new!()

config :uro, Uro.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: Map.take(url, [:scheme, :host, :path]),
  http: [
    port:
      "PORT"
      |> Helpers.get_env("4000")
      |> String.to_integer()
  ]
