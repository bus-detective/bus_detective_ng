defmodule Realtime.VehiclePositionFinder do
  @moduledoc """
  This is a module that contains functions to find realtime vehicle positions
  """

  alias Realtime.Messages.FeedMessage
  alias Realtime.VehiclePosition

  def find_vehicle_position(%FeedMessage{} = feed, trip_remote_id) do
    feed
    |> Map.get(:entity)
    |> Enum.filter(&filter_by_trip(&1, trip_remote_id))
    |> Enum.map(&VehiclePosition.from_message/1)
    |> Enum.at(0)
  end

  def filter_by_trip(feed_entity, trip_remote_id) do
    feed_entity
    |> Map.get(:vehicle)
    |> Map.get(:trip)
    |> Map.get(:trip_id)
    |> Kernel.==(trip_remote_id)
  end
end
