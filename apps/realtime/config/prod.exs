use Mix.Config

config :realtime,
  feeds: %{
    System.get_env("FEED_NAME") => %{
      trip_updates_url: System.get_env("FEED_TRIP_UPDATES_URL"),
      vehicle_positions_url: System.get_env("FEED_VEHICLE_POSITIONS_URL")
    }
  }
