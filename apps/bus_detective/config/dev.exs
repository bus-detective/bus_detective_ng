use Mix.Config

# Configure your database
config :bus_detective, BusDetective.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bus_detective_dev",
  hostname: "localhost",
  pool_size: 10,
  types: BusDetective.PostgresTypes
