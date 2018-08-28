defmodule Realtime.VehiclePositionFinder do
  @moduledoc """
  This is a module that contains functions to find realtime vehicle positions
  """

  alias Realtime.Messages.{FeedEntity, FeedMessage, TripDescriptor}
  alias Realtime.VehiclePosition

  def find_vehicle_position(%FeedMessage{} = feed, trip_remote_id) do
    feed
    |> Map.get(:entity)
    |> Enum.filter(&filter_by_trip(&1, trip_remote_id))
    |> Enum.map(&VehiclePosition.from_message/1)
    |> Enum.at(0)
  end

  def filter_by_trip(
        %FeedEntity{vehicle: %Realtime.Messages.VehiclePosition{trip: %TripDescriptor{trip_id: trip_id}}},
        trip_remote_id
      ) do
    trip_id == trip_remote_id
  end

  def filter_by_trip(_, _), do: false
end
