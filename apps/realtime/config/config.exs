use Mix.Config

config :realtime,
  feeds: %{
    "SORTA" => %{
      trip_updates_url: "http://developer.go-metro.com/TMGTFSRealTimeWebService/TripUpdate/TripUpdates.pb",
      vehicle_positions_url: "http://developer.go-metro.com/TMGTFSRealTimeWebService/vehicle/VehiclePositions.pb"
    }
    # "King County" => %{
    #   trip_updates_url: "http://api.pugetsound.onebusaway.org/api/gtfs_realtime/trip-updates-for-agency/1.pb?key=TEST",
    #   vehicle_positions_url: "http://api.pugetsound.onebusaway.org/api/gtfs_realtime/vehicle-positions-for-agency/1.pb?key=TEST"
    # }
  }

config :realtime, Realtime.TripUpdates, enabled: true

config :realtime, Realtime.VehiclePositions, enabled: true

file = Path.join(Path.dirname(__ENV__.file), "#{Mix.env()}.exs")

if File.exists?(file) do
  import_config file
end
