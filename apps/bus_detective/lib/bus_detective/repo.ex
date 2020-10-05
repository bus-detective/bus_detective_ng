defmodule BusDetective.Repo do
  use Ecto.Repo, otp_app: :bus_detective,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bus_detective_dev",
  hostname: "localhost",
  pool_size: 10,
  types: BusDetective.PostgresTypes
  
  use Scrivener, page_size: 100

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
