import Config

# Unused (no static files)
# config :uro, Uro.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# TODO: Replace with correct adapter in production
config :uro, Uro.Mailer, adapter: Swoosh.Adapters.Local

# Do not print debug messages in production.
config :logger, level: :info
