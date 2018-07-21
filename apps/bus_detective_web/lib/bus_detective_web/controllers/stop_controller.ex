defmodule BusDetectiveWeb.StopController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS

  action_fallback(BusDetectiveWeb.FallbackController)

  def show(conn, %{"id" => stop_id_str}) do
    with {stop_id, ""} <- Integer.parse(stop_id_str),
         duration = 1,
         stop <- GTFS.get_stop!(stop_id),
         start_time <- Timex.shift(Timex.now(), minutes: -10),
         end_time <- Timex.shift(Timex.now(), hours: duration) do
      departures = GTFS.departures_for_stop(stop, start_time, end_time)
      render(conn, "show.html", stop: stop, departures: departures)
    end
  end
end
