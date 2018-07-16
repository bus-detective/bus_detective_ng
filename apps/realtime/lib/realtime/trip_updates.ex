defmodule Realtime.TripUpdates do
  @moduledoc """
  This module contains the functions for processing a realtime feed's trip updates
  """

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{StopTime, Trip}
  alias Realtime.Messages.{FeedEntity, FeedMessage, TripDescriptor, TripUpdate}
  alias Realtime.StopTimeUpdate

  def find_stop_time(%FeedMessage{} = feed, %StopTime{trip: trip} = stop_time) do
    with nil <- find_trip(feed, trip),
         nil <- find_related_trip(feed, trip) do
      nil
    else
      %TripUpdate{} = trip_update ->
        find_stop_time(trip_update, stop_time)
    end
  end

  def find_stop_time(%TripUpdate{trip: %TripDescriptor{trip_id: remote_id}} = trip_update, %StopTime{
        trip: %Trip{remote_id: remote_id},
        stop_sequence: stop_sequence
      }) do
    trip_update
    |> Map.get(:stop_time_update)
    |> Enum.filter(&(&1.stop_sequence <= stop_sequence))
    |> Enum.sort_by(& &1.stop_sequence, &>=/2)
    |> Enum.at(0)
    |> StopTimeUpdate.from_message()
  end

  def find_stop_time(%TripUpdate{} = trip_update, _) do
    trip_update
    |> Map.get(:stop_time_update)
    |> Enum.sort_by(& &1.stop_sequence, &>=/2)
    |> Enum.at(0)
    |> StopTimeUpdate.from_message()
  end

  def find_trip(%FeedMessage{} = feed, %Trip{remote_id: remote_id}) do
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

  def find_related_trip(%FeedMessage{} = feed, %Trip{block_id: block_id}) do
    trip_remote_ids =
      block_id
      |> GTFS.get_trips_in_block()
      |> Enum.map(& &1.remote_id)

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
end

defmodule Realtime.StopTimeUpdate do
  @moduledoc """
  A flattened version of a StopTimeUpdate useful for overlaying on top of scheduled StopTimes
  """

  defstruct [:departure_time, :delay, :stop_id, :stop_sequence]

  alias Realtime.Messages.TripUpdate.StopTimeUpdate, as: StopTimeUpdateMessage
  alias Realtime.Messages.TripUpdate.StopTimeEvent

  def from_message(%StopTimeUpdateMessage{} = message) do
    with {:ok, departure} <- departure(message.arrival, message.departure),
         {:ok, departure_time} <- departure_time(departure) do
      %__MODULE__{
        departure_time: departure_time,
        delay: departure.delay,
        stop_id: message.stop_id,
        stop_sequence: message.stop_sequence
      }
    end
  end

  def from_message(_), do: nil

  defp departure(_, %StopTimeEvent{} = departure), do: {:ok, departure}

  defp departure(arrival, nil), do: {:ok, arrival}

  defp departure(_, _), do: {:error, :no_departure}

  defp departure_time(nil), do: {:error, :no_departure_time}

  defp departure_time(%StopTimeEvent{} = departure) do
    DateTime.from_unix(departure.time)
  end
end
