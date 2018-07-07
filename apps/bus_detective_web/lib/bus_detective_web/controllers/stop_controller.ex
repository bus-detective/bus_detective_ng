defmodule BusDetectiveWeb.StopController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS
  alias BusDetectiveWeb.ErrorView

  action_fallback BusDetectiveWeb.FallbackController

  def index(conn, %{"query" => query}) do
    stops = GTFS.search_stops(query: query)
    render(conn, "index.json", stops: stops)
  end

  def index(conn, _) do
    conn
    |> put_status(:bad_request)
    |> render(ErrorView, "400.json")
  end

  # def show(conn, %{"id" => id}) do
  #   stop = GTFS.get_stop!(id)
  #   render(conn, "show.json", stop: stop)
  # end
end
