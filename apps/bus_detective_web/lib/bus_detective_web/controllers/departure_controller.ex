defmodule BusDetectiveWeb.DepartureController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Departure
  alias Timex.Timezone

  action_fallback(BusDetectiveWeb.FallbackController)

  def index(conn, %{"stop_id" => stop_id_str, "duration" => duration_str}) do
    with {stop_id, ""} <- Integer.parse(stop_id_str),
         {duration, ""} <- Integer.parse(duration_str),
         stop <- GTFS.get_stop!(stop_id),
         start_time <- Timex.shift(agency_time(stop.agency), minutes: -10),
         end_time <- Timex.shift(agency_time(stop.agency), hours: duration) do
      departures =
        stop
        |> GTFS.calculated_stop_times_between(start_time, end_time)
        |> Enum.map(fn stop_time ->
          %Departure{
            scheduled_time: stop_time.calculated_departure_time,
            time: stop_time.calculated_departure_time,
            realtime?: false,
            delay: 0,
            trip: stop_time.trip,
            route: stop_time.trip.route
          }
        end)

      render(conn, "index.json", departures: departures)
    end
  end

  defp agency_time(agency) do
    timezone = Timezone.get(agency.timezone)
    Timezone.convert(Timex.now(), timezone)
  end
end
