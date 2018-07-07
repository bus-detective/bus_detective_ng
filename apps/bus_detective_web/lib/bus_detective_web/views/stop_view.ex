defmodule BusDetectiveWeb.StopView do
  use BusDetectiveWeb, :view

  alias BusDetective.GTFS.Stop
  alias BusDetectiveWeb.{AgencyView, RouteView, StopView}

  def render("index.json", %{stops: stops}) do
    %{data: render_many(stops, StopView, "stop.json")}
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
