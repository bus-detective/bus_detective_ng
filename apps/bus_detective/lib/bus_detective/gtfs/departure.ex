defmodule BusDetective.GTFS.Departure do
  @moduledoc false
  defstruct [:realtime?, :time, :delay, :scheduled_time, :route, :trip, :agency]
end
