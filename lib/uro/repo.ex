defmodule Uro.Repo do
  use Ecto.Repo,
    otp_app: :uro,
    adapter: Ecto.Adapters.SQLite3

  use Scrivener, page_size: 10
end
