defmodule BusDetectiveWeb.TripController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS

  action_fallback(BusDetectiveWeb.FallbackController)

  def index(conn, %{"ids" => ids}) do
    results = GTFS.get_trips(ids)
    render(conn, "index.json", results: results)
  end
end
