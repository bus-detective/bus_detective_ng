use Mix.Config

config :realtime,
  feeds: %{
    "SORTA" => %{
      trip_updates_url: "http://developer.go-metro.com/TMGTFSRealTimeWebService/TripUpdate/TripUpdates.pb",
      vehicle_positions_url: "http://developer.go-metro.com/TMGTFSRealTimeWebService/vehicle/VehiclePositions.pb"
    }
  }

config :realtime, Realtime.TripUpdates, enabled: true

config :realtime, Realtime.VehiclePositions, enabled: true

file = Path.join(Path.dirname(__ENV__.file), "#{Mix.env()}.exs")

if File.exists?(file) do
  import_config file
end
