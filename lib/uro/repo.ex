defmodule Uro.Repo do
  use Ecto.Repo,
    otp_app: :uro,
    adapter: Ecto.Adapters.Postgres
end
