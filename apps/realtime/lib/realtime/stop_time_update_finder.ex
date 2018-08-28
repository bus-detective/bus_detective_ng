defmodule Realtime.StopTimeUpdateFinder do
  @moduledoc """
  This module contains the functions for processing a realtime feed's trip updates
  """

  alias Realtime.Messages.{FeedEntity, FeedMessage, TripDescriptor, TripUpdate}
  alias Realtime.StopTimeUpdate

  def find_exact_trip(%FeedMessage{} = feed, remote_id) do
    feed
    |> Map.get(:entity)
    |> Enum.filter(&exact_trip_match?(&1, remote_id))
    |> Enum.map(& &1.trip_update)
    |> Enum.at(0)
  end

  def find_stop_time_update(%FeedMessage{} = feed, trip_remote_id, stop_sequence) do
    with %TripUpdate{} = trip_update <- find_exact_trip(feed, trip_remote_id),
         %StopTimeUpdate{} = stop_time_update <- find_exact_stop_time_update(trip_update, stop_sequence) do
      stop_time_update
    else
      _ -> nil
    end
  end

  defp exact_trip_match?(
         %FeedEntity{trip_update: %TripUpdate{trip: %TripDescriptor{trip_id: trip_remote_id}}},
         trip_remote_id
       ),
       do: true

  defp exact_trip_match?(_, _), do: false

  defp find_exact_stop_time_update(
         %TripUpdate{stop_time_update: stop_time_updates},
         stop_sequence
       ) do
    stop_time_updates
    |> Enum.filter(&(is_nil(&1.stop_sequence) || &1.stop_sequence == stop_sequence))
    |> Enum.at(0)
    |> StopTimeUpdate.from_message()
  end
end
