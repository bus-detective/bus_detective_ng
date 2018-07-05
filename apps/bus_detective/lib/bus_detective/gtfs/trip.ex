defmodule BusDetective.GTFS.Trip do
  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, Route, Service, Shape}

  schema "trips" do
    belongs_to(:agency, Agency)
    belongs_to(:route, Route)
    belongs_to(:service, Service)
    belongs_to(:shape, Shape)
    field(:bikes_allowed, :integer)
    field(:block_id, :integer)
    field(:direction_id, :integer)
    field(:headsign, :string)
    field(:remote_id, :string)
    field(:short_name, :string)
    field(:wheelchair_accessible, :integer)

    timestamps()
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [
      :agency_id,
      :service_id,
      :route_id,
      :shape_id,
      :remote_id,
      :headsign,
      :short_name,
      :direction_id,
      :block_id,
      :wheelchair_accessible,
      :bikes_allowed
    ])
    |> validate_required([
      :agency_id,
      :service_id,
      :route_id,
      :remote_id
    ])
  end
end
