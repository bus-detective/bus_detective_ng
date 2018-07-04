defmodule BusDetective.GTFS.StopTime do
  use Ecto.Schema
  import Ecto.Changeset


  schema "stop_times" do
    field :agency_id, :integer
    field :arrival_time, :integer
    field :departure_time, :integer
    field :drop_off_type, :integer
    field :pickup_type, :integer
    field :shape_dist_traveled, :float
    field :stop_headsign, :string
    field :stop_id, :integer
    field :stop_sequence, :integer
    field :trip_id, :integer

    timestamps()
  end

  @doc false
  def changeset(stop_time, attrs) do
    stop_time
    |> cast(attrs, [:agency_id, :stop_id, :trip_id, :stop_headsign, :pickup_type, :drop_off_type, :shape_dist_traveled, :arrival_time, :departure_time, :stop_sequence])
    |> validate_required([:agency_id, :stop_id, :trip_id, :stop_headsign, :pickup_type, :drop_off_type, :shape_dist_traveled, :arrival_time, :departure_time, :stop_sequence])
  end
end
