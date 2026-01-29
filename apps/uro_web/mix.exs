defmodule UroWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :uro_web,
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
      mod: {UroWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:uro_api, in_umbrella: true},
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:bandit, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"}
    ]
  end

  defp aliases do
    [
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind uro_web", "esbuild uro_web"],
      "assets.deploy": [
        "tailwind uro_web --minify",
        "esbuild uro_web --minify",
        "phx.digest"
      ]
    ]
  end
end
