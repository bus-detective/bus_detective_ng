defmodule BusDetectiveWeb.StopView do
  use BusDetectiveWeb, :view

  alias BusDetective.GTFS.Stop
  alias BusDetectiveWeb.{AgencyView, RouteView, StopView}

  def render("index.json", %{results: results}) do
    %{
      data: %{
        total_results: results.total_entries,
        total_pages: results.total_pages,
        page: results.page_number,
        per_page: results.page_size,
        results: render_many(results.entries, StopView, "stop.json")
      }
    }
  end

  def render("show.json", %{stop: stop}) do
    %{data: render_one(stop, StopView, "stop.json")}
  end

  def render("stop.json", %{stop: stop}) do
    %{
      agency: render_one(stop.agency, AgencyView, "agency.json"),
      direction: Stop.direction(stop),
      id: stop.id,
      latitude: stop.latitude,
      longitude: stop.longitude,
      name: stop.name,
      routes: render_many(stop.routes, RouteView, "route.json")
    }
  end
end
