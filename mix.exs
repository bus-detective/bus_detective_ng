defmodule BusDetective.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(Mix.env()),
      apps_path: "apps",
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      releases: [
        foo: [
          version: "0.0.1",
          applications: [
            bus_detective: :permanent,
            bus_detective_web: :permanent,
            importer: :permanent,
            realtime: :permanent
          ]
        ]
      ]
    ]
  end

  defp aliases(:dev), do: []

  defp aliases(_) do
    # [compile: "compile --warnings-as-errors"]
    []
  end

  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:excoveralls, "~> 0.8", only: :test},
      {:phoenix, "~> 1.4.6"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.2.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:peerage, "~> 1.0"}
    ]
  end
end
