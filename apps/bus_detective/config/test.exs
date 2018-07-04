use Mix.Config

# Configure your database
config :bus_detective, BusDetective.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bus_detective_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  types: BusDetective.PostgresTypes
