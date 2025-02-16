require Logger

defmodule Uro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    validate_env()

    children =
      if System.get_env("MINIMAL_START") == "true",
        do: [],
        else: [
          Uro.Repo,
          Uro.Endpoint,
          Uro.VSekai.ShardJanitor,
          {Redix, {Application.get_env(:uro, Redix)[:url], [name: :redix]}},
          {Phoenix.PubSub, [name: Uro.PubSub, adapter: Phoenix.PubSub.PG2]}
        ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp validate_env do
    env_vars = ["TURNSTILE_SECRET_KEY"]

    for var <- env_vars do
      err_msg =
        case var do
          "TURNSTILE_SECRET_KEY" ->
            "Turnstile (a reCaptcha alternative) is disabled because the environment variable TURNSTILE_SECRET_KEY is not set. For more information, see https://developers.cloudflare.com/turnstile/get-started/."

          _ ->
            "Environment variable #{var} is not set"
        end

      case System.get_env(var) do
        "" -> Logger.warning(err_msg)
        nil -> Logger.warning(err_msg)
        _ -> Logger.info("Environment variable #{var} is set")
      end
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Uro.Endpoint.config_change(changed, removed)
    :ok
  end
end
