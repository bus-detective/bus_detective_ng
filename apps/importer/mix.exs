defmodule Importer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :importer,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(Mix.env()),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Importer.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:briefly, "~> 0.3"},
      {:bus_detective, in_umbrella: true},
      {:csv, "~> 2.0.0"},
      {:httpoison, "~> 0.12"},
      {:timex, "~> 3.1"}
    ]
  end

  defp aliases(:dev), do: []

  defp aliases(_) do
    [compile: "compile --warnings-as-errors"]
  end
end
