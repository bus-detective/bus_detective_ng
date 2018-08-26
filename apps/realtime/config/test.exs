use Mix.Config

config :realtime, feeds: %{}

config :realtime, :trip_updates_source, Realtime.TripUpdatesMock

config :realtime, :vehicle_positions_source, Realtime.VehiclePositionsMock

config :realtime, Realtime.TripUpdates, enabled: false

config :realtime, Realtime.VehiclePositions, enabled: false
