use Mix.Config

config :bus_detective, ecto_repos: [BusDetective.Repo]

import_config "#{Mix.env}.exs"
