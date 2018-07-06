defmodule BusDetective.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(Mix.env()),
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp aliases(:dev), do: []

  defp aliases(_) do
    [compile: "compile --warnings-as-errors"]
  end

  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    []
  end
end
