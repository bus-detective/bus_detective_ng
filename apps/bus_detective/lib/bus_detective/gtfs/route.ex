defmodule BusDetective.GTFS.Route do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, Feed, RouteStop, Trip}

  schema "routes" do
    belongs_to(:feed, Feed)
    belongs_to(:agency, Agency)

    field(:color, :string)
    field(:description, :string)
    field(:long_name, :string)
    field(:remote_id, :string)
    field(:route_type, :string)
    field(:short_name, :string)
    field(:text_color, :string)
    field(:url, :string)

    has_many(:route_stops, RouteStop, on_delete: :delete_all)
    has_many(:stops, through: [:route_stops, :stop])
    has_many(:trips, Trip, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [
      :feed_id,
      :agency_id,
      :remote_id,
      :short_name,
      :long_name,
      :description,
      :route_type,
      :url,
      :color,
      :text_color
    ])
    |> validate_required([
      :feed_id,
      :agency_id,
      :remote_id,
      :short_name,
      :long_name,
      :route_type
    ])
    |> unique_constraint(:remote_id, name: :routes_feed_id_remote_id_index)
  end
end
