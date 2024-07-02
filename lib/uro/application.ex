defmodule Uro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Uro.Repo,

      # Start the endpoint when the application starts
      Uro.Endpoint,
      Uro.VSekai.ShardJanitor,

      # Starts a worker by calling: Uro.Worker.start_link(arg)
      # {Uro.Worker, arg},

      # Starts Pow's Mnesia-backed cache store
      # Pow.Store.Backend.MnesiaCache,
      # # Or in a distributed system:
      # {Pow.Store.Backend.MnesiaCache, extra_db_nodes: Node.list()},
      # Pow.Store.Backend.MnesiaCache.Unsplit # Recover from netsplit
      {Redix, {Application.get_env(:uro, Redix)[:url], [name: :redix]}},
      {Phoenix.PubSub, [name: Uro.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Uro.Endpoint.config_change(changed, removed)
    :ok
  end
end
