use Mix.Config

config :realtime,
  feeds: %{
    "SORTA" => %{
      trip_updates_url: "http://developer.go-metro.com/TMGTFSRealTimeWebService/TripUpdate/TripUpdates.pb"
    }
  }
