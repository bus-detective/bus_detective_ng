defmodule BusDetectiveWeb.RouteController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Route}

  action_fallback(BusDetectiveWeb.FallbackController)

  def index(conn, %{"agency_id" => agency_id}) do
    routes = GTFS.list_routes(%Agency{id: agency_id})
    render(conn, "index.json", routes: routes)
  end
end
