ExUnit.start()

Mox.defmock(Realtime.VehiclePositionsMock, for: Realtime.VehiclePositionsSource)
Mox.defmock(Realtime.TripUpdatesMock, for: Realtime.TripUpdatesSource)
