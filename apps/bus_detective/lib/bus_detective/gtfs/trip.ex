defmodule BusDetective.GTFS.Trip do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Feed, Route, Service, Shape}

  schema "trips" do
    belongs_to(:feed, Feed)
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
      :feed_id,
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
      :feed_id,
      :service_id,
      :route_id,
      :remote_id
    ])
    |> unique_constraint(:remote_id, name: :trips_feed_id_remote_id_index)
  end
end
