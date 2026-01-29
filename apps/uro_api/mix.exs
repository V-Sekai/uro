defmodule UroApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :uro_api,
      version: "0.1.0",
      elixir: "~> 1.17 or ~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Uro.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :email_checker,
        :mnesia,
        :scrivener_ecto,
        :httpoison
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.11"},
      {:redix, "~> 0.9.2"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.6"},
      {:bandit, "~> 1.0"},
      {:comeonin, "~> 5.3.2"},
      {:bcrypt_elixir, "~> 2.3"},
      {:pow, "~> 1.0"},
      {:email_checker, "~> 0.1.4"},
      {:pow_assent, "~> 0.4.18"},
      {:ssl_verify_fun, "~> 1.1.6"},
      {:open_api_spex, "~> 3.18"},
      {:ex_json_schema, "~> 0.7.4"},
      {:remote_ip, "~> 1.0"},
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.0.10"},
      {:ecto_commons, "~> 0.3.4"},
      {:hammer, "~> 6.0"},
      {:scrivener_ecto, "~> 2.7"},
      {:ex_marcel, "~> 0.1.0"},
      {:hackney, "~> 1.17"},
      {:httpoison, "~> 2.0"},
      {:gettext, "~> 0.18"},
      {:swoosh, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
