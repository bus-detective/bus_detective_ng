defmodule BusDetectiveWeb.TripView do
  use BusDetectiveWeb, :view

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
