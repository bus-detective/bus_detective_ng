defmodule BusDetective.GTFS.RouteStop do
  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Route, Stop}

  schema "routes_stops" do
    belongs_to(:route, Route)
    belongs_to(:stop, Stop)
  end

  @doc false
  def changeset(route_stop, attrs) do
    route_stop
    |> cast(attrs, [:route_id, :stop_id])
    |> validate_required([:route_id, :stop_id])
  end
end
