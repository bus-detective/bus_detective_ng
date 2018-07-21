defmodule Realtime.StopTimeUpdateFinder do
  @moduledoc """
  This module contains the functions for processing a realtime feed's trip updates
  """

  alias Realtime.Messages.{FeedEntity, FeedMessage, TripDescriptor, TripUpdate}
  alias Realtime.StopTimeUpdate

  def find_stop_time(%FeedMessage{} = feed, block_id, trip_remote_id, stop_sequence, fetch_related_trips_fn) do
    with nil <- find_trip(feed, trip_remote_id),
         nil <- find_related_trip(feed, block_id, fetch_related_trips_fn) do
      nil
    else
      %TripUpdate{} = trip_update ->
        _find_stop_time(trip_update, trip_remote_id, stop_sequence)
    end
  end

  def find_trip(%FeedMessage{} = feed, remote_id) do
    feed
    |> Map.get(:entity)
    |> Enum.filter(fn
      %FeedEntity{trip_update: %TripUpdate{trip: %TripDescriptor{trip_id: ^remote_id}}} ->
        true

      _ ->
        false
    end)
    |> Enum.map(& &1.trip_update)
    |> Enum.at(0)
  end

  def find_related_trip(%FeedMessage{} = feed, block_id, fetch_related_trips_fn) do
    trip_remote_ids = fetch_related_trips_fn.(block_id)

    feed
    |> Map.get(:entity)
    |> Enum.filter(fn
      %FeedEntity{trip_update: %TripUpdate{trip: %TripDescriptor{trip_id: trip_id}}} ->
        trip_id in trip_remote_ids

      _ ->
        false
    end)
    |> Enum.map(& &1.trip_update)
    |> Enum.at(0)
  end

  defp _find_stop_time(
         %TripUpdate{stop_time_update: stop_time_updates, trip: %TripDescriptor{trip_id: trip_id}},
         remote_trip_id,
         stop_sequence
       ) do
    stop_time_updates
    |> maybe_filter_stop_time_updates(stop_sequence, trip_id == remote_trip_id)
    |> Enum.sort_by(& &1.stop_sequence, &>=/2)
    |> Enum.at(0)
    |> StopTimeUpdate.from_message()
  end

  defp maybe_filter_stop_time_updates(stop_time_updates, _, false), do: stop_time_updates

  defp maybe_filter_stop_time_updates(stop_time_updates, stop_sequence, true) do
    Enum.filter(stop_time_updates, &(&1.stop_sequence <= stop_sequence))
  end
end
