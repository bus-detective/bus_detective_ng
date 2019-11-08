defmodule BusDetective.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(Mix.env()),
      app: :bus_detective,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "../../mix.lock",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.0.1"
    ]
  end

  defp aliases(env) do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ] ++ env_aliases(env)
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BusDetective.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.0"},
      {:ex_cldr, "~> 1.6.4"},
      {:ex_cldr_numbers, "~> 1.5.1"},
      {:ex_machina, "~> 2.3", only: [:dev, :test]},
      {:geo_postgis, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:realtime, in_umbrella: true},
      {:scrivener_ecto, "~> 2.2.0"},
      {:timex, "~> 3.1"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp env_aliases(:dev), do: []

  defp env_aliases(_) do
    # [compile: "compile --warnings-as-errors"]
    []
  end
end
