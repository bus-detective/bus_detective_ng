defmodule BusDetective.GTFS.StopTime do
  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, Stop, Trip}

  schema "stop_times" do
    belongs_to(:agency, Agency)
    belongs_to(:stop, Stop)
    belongs_to(:trip, Trip)
    # Interval is not the right thing to use here, since it's months, days and secs
    # we want hours, minutes, seconds
    # keeping it in Interval format for the short term to maintain consistency with
    # Rails BD.
    field(:arrival_time, :integer)
    field(:departure_time, :integer)
    field(:drop_off_type, :integer)
    field(:pickup_type, :integer)
    field(:shape_dist_traveled, :float)
    field(:stop_headsign, :string)
    field(:stop_sequence, :integer)

    timestamps()
  end

  @doc false
  def changeset(stop_time, attrs) do
    stop_time
    |> cast(attrs, [
      :agency_id,
      :stop_id,
      :trip_id,
      :stop_headsign,
      :pickup_type,
      :drop_off_type,
      :shape_dist_traveled,
      :arrival_time,
      :departure_time,
      :stop_sequence
    ])
    |> validate_required([
      :agency_id,
      :stop_id,
      :trip_id,
      :arrival_time,
      :departure_time,
      :stop_sequence
    ])
  end
end
