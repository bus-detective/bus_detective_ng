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
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp aliases(:dev), do: []

  defp aliases(_) do
    [compile: "compile --warnings-as-errors"]
  end

  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [{:excoveralls, "~> 0.8", only: :test}]
  end
end
