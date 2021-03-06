use Mix.Config

config :importer,
  schedules: %{
    "SORTA" => %{
      gtfs_schedule_url: "https://www.go-metro.com/uploads/GTFS/google_transit_info.zip"
    }
  }

file = Path.join(Path.dirname(__ENV__.file), "dev.secret.exs")

if File.exists?(file) do
  import_config file
end
