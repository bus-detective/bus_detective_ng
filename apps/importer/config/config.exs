use Mix.Config

config :importer, ecto_repos: [BusDetective.Repo]

import_config Path.join(Path.dirname(__ENV__.file), "#{Mix.env()}.exs")
