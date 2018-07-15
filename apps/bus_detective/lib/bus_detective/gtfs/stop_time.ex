defmodule BusDetective.GTFS.StopTime do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, Interval, ProjectedStopTime, Stop, Trip}

  schema "stop_times" do
    belongs_to(:agency, Agency)
    belongs_to(:stop, Stop)
    belongs_to(:trip, Trip)

    field(:arrival_time, Interval)
    field(:calculated_arrival_time, :utc_datetime, virtual: true)
    field(:calculated_departure_time, :utc_datetime, virtual: true)
    field(:departure_time, Interval)
    field(:drop_off_type, :integer)
    field(:pickup_type, :integer)
    field(:shape_dist_traveled, :float)
    field(:stop_headsign, :string)
    field(:stop_sequence, :integer)

    has_many(:projected_stop_times, ProjectedStopTime, on_delete: :delete_all)

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
