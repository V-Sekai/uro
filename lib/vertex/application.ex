defmodule Vertex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Vertex.Repo,

      # Start the endpoint when the application starts
      VertexWeb.Endpoint,
      Vertex.VSekai.ShardJanitor,

      # Starts a worker by calling: Vertex.Worker.start_link(arg)
      # {Vertex.Worker, arg},

      # Starts Pow's Mnesia-backed cache store
      Pow.Store.Backend.MnesiaCache,
      # # Or in a distributed system:
      # {Pow.Store.Backend.MnesiaCache, extra_db_nodes: Node.list()},
      # Pow.Store.Backend.MnesiaCache.Unsplit # Recover from netsplit
      {Phoenix.PubSub, [name: Vertex.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vertex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VertexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
