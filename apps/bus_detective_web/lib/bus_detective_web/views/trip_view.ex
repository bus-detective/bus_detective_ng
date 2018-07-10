defmodule BusDetectiveWeb.TripView do
  use BusDetectiveWeb, :view

  alias BusDetectiveWeb.{RouteView, ShapeView, TripView}

  def render("index.json", %{results: results}) do
    %{trips: render_many(results, TripView, "trip-detailed.json")}
  end

  def render("trip-detailed.json", %{trip: trip}) do
    %{
      id: trip.id,
      headsign: trip.headsign,
      block_id: trip.block_id,
      remote_id: trip.remote_id,
      route: render_one(trip.route, RouteView, "route.json"),
      shape: render_one(trip.shape, ShapeView, "shape.json")
    }
  end

  def render("trip.json", %{trip: trip}) do
    %{
      id: trip.id,
      headsign: trip.headsign,
      shape_id: trip.shape_id,
      block_id: trip.block_id,
      remote_id: trip.remote_id
    }
  end
end
