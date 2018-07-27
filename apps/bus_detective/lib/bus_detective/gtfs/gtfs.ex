defmodule BusDetective.GTFS do
  @moduledoc """
  The GTFS context module contains all of the functions needed to serve requests
  about scheduled or realtime GTFS data
  """

  import Ecto.Query, warn: false

  require Logger

  alias BusDetective.GTFS.{
    Departure,
    Feed,
    ProjectedStopTime,
    Stop,
    StopTime,
    Trip
  }

  alias BusDetective.Repo
  alias Realtime.{StopTimeUpdate, TripUpdates}

  @doc """
  This function takes projected stop times for the given stop and time range,
  and overlays realtime data for the stop times if available.
  """
  def departures_for_stop(stop, start_time, end_time) do
    stop
    |> projected_stop_times_for_stop(start_time, end_time)
    |> Enum.map(fn projected_stop_time ->
      %ProjectedStopTime{
        stop_time: %StopTime{
          feed: %Feed{name: feed_name},
          trip: %Trip{remote_id: trip_remote_id},
          stop_sequence: stop_sequence
        }
      } = projected_stop_time

      case TripUpdates.find_stop_time(feed_name, trip_remote_id, stop_sequence) do
        {:ok, %StopTimeUpdate{} = stop_time_update} ->
          %Departure{
            scheduled_time: projected_stop_time.scheduled_departure_time,
            time: stop_time_update.departure_time,
            realtime?: true,
            delay: stop_time_update.delay,
            trip: projected_stop_time.stop_time.trip,
            route: projected_stop_time.stop_time.trip.route,
            agency: projected_stop_time.stop_time.trip.route.agency
          }

        _ ->
          %Departure{
            scheduled_time: projected_stop_time.scheduled_departure_time,
            time: projected_stop_time.scheduled_departure_time,
            realtime?: false,
            delay: 0,
            trip: projected_stop_time.stop_time.trip,
            route: projected_stop_time.stop_time.trip.route,
            agency: projected_stop_time.stop_time.trip.route.agency
          }
      end
    end)
    |> Enum.sort_by(&Timex.to_erl(&1.time))
  end

  def projected_stop_times_for_stop(%Stop{id: stop_id}, %DateTime{} = start_time, %DateTime{} = end_time) do
    Repo.all(
      from(
        projected in ProjectedStopTime,
        join: stop_time in assoc(projected, :stop_time),
        where: stop_time.stop_id == ^stop_id,
        where: projected.scheduled_departure_time >= ^start_time,
        where: projected.scheduled_departure_time <= ^end_time,
        order_by: [:scheduled_departure_time],
        preload: [stop_time: [:feed, trip: [:shape, route: :agency]]]
      )
    )
  end

  def search_stops(options) do
    query = Keyword.get(options, :query)
    pagination_options = options

    Repo.paginate(
      from(
        s in Stop,
        where: fragment("? ILIKE ?", s.name, ^"%#{query}%"),
        preload: [:routes, :feed]
      ),
      pagination_options
    )
  end

  def get_stop!(id) do
    Stop
    |> Repo.get!(id)
    |> Repo.preload([:feed, :routes])
  end
end
