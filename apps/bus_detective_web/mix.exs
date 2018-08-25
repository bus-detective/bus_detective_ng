defmodule BusDetectiveWeb.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(Mix.env()),
      app: :bus_detective_web,
      build_path: "../../_build",
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test,
        "coveralls.html": :test
      ],
      version: "0.0.1"
    ]
  end

  defp aliases(:dev), do: []

  defp aliases(_) do
    [
      compile: "compile --warnings-as-errors",
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BusDetectiveWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bus_detective, in_umbrella: true},
      {:cowboy, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:mox, "~> 0.4", only: :test},
      {:phoenix, "~> 1.3.3"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:wallaby, "~> 0.20.0", [runtime: false, only: :test]}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
