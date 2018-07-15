defmodule BusDetective.GTFS.ProjectedStopTime do
  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.StopTime

  schema "projected_stop_times" do
    belongs_to(:stop_time, StopTime)
    field(:scheduled_arrival_time, :utc_datetime)
    field(:scheduled_departure_time, :utc_datetime)

    timestamps()
  end

  @doc false
  def changeset(projected_stop_time, attrs) do
    projected_stop_time
    |> cast(attrs, [:scheduled_arrival_time, :scheduled_departure_time])
    |> validate_required([:scheduled_arrival_time, :scheduled_departure_time])
  end
end
