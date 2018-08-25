use Mix.Config

config :realtime, feeds: %{}

config :realtime, Realtime.TripUpdates, enabled: false

config :realtime, Realtime.VehiclePositions, enabled: false
