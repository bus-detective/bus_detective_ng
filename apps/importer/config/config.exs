use Mix.Config

config :importer, ecto_repos: [BusDetective.Repo]

config :importer,
  schedules: %{
    "SORTA" => %{
      gtfs_schedule_url: "http://www.go-metro.com/uploads/GTFS/google_transit_info.zip"
    }
  }

file = Path.join(Path.dirname(__ENV__.file), "#{Mix.env()}.exs")

if File.exists?(file) do
  import_config file
end
