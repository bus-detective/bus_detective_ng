use Mix.Config

# kubernetes ...
config :el_kube, ElKubeWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

# Ecto config
config :bus_detective, BusDetective.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bus_detective_dev",
  hostname: "localhost",
  pool_size: 10,
  types: BusDetective.PostgresTypes

# Do not print debug messages in production
config :logger, level: :info
