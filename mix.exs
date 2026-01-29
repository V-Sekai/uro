defmodule Uro.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        paths: [
          "_build/dev/lib/uro_api/ebin",
          "_build/dev/lib/uro_web/ebin"
        ],
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "uro.apigen": [
        "openapi.spec.json --spec Uro.OpenAPI.Specification --pretty --vendor-extensions=false ./frontend/src/__generated/openapi.json"
      ],

      # Not required, fixes warning https://github.com/chaskiq/ex-marcel/pull/2
      "patch.exmarcel": fn _args ->
        path = "deps/ex_marcel/lib/magic.ex"

        patched =
          String.replace(
            File.read!(path),
            "ext |> String.slice(1..-1)",
            "ext |> String.slice(1..-1//1)"
          )

        File.write!(path, patched)
        IO.puts("Module 'ex_marcel' patched successfully!")
      end,
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
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
