defmodule BusDetective.GTFS.Trip do
  use Ecto.Schema
  import Ecto.Changeset


  schema "trips" do
    field :agency_id, :integer
    field :bikes_allowed, :integer
    field :block_id, :integer
    field :direction_id, :integer
    field :headsign, :string
    field :remote_id, :string
    field :route_id, :integer
    field :service_id, :integer
    field :shape_id, :integer
    field :short_name, :string
    field :wheelchair_accessible, :integer

    timestamps()
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [:agency_id, :service_id, :route_id, :shape_id, :remote_id, :headsign, :short_name, :direction_id, :block_id, :wheelchair_accessible, :bikes_allowed])
    |> validate_required([:agency_id, :service_id, :route_id, :shape_id, :remote_id, :headsign, :short_name, :direction_id, :block_id, :wheelchair_accessible, :bikes_allowed])
  end
end
