defmodule Uro.Repo do
  use Ecto.Repo,
    otp_app: :uro_api,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
