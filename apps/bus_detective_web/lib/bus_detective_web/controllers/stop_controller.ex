defmodule BusDetectiveWeb.StopController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Departure

  action_fallback(BusDetectiveWeb.FallbackController)

  def show(conn, %{"id" => stop_id_str}) do
    with {stop_id, ""} <- Integer.parse(stop_id_str),
         duration = 1,
         stop <- GTFS.get_stop!(stop_id),
         start_time <- Timex.shift(Timex.now(), minutes: -10),
         end_time <- Timex.shift(Timex.now(), hours: duration) do
      departures =
        stop
        |> GTFS.projected_stop_times_for_stop(start_time, end_time)
        |> Enum.map(fn projected_stop_time ->
          %Departure{
            scheduled_time: projected_stop_time.scheduled_departure_time,
            time: projected_stop_time.scheduled_departure_time,
            realtime?: false,
            delay: 0,
            trip: projected_stop_time.stop_time.trip,
            route: projected_stop_time.stop_time.trip.route
          }
        end)

      render(conn, "show.html", stop: stop, departures: departures)
    end
  end
end
