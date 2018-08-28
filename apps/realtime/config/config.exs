use Mix.Config

config :realtime, Realtime.TripUpdates, enabled: true

config :realtime, Realtime.VehiclePositions, enabled: true

import_config Path.join(Path.dirname(__ENV__.file), "#{Mix.env()}.exs")
