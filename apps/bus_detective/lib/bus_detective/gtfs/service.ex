defmodule BusDetective.GTFS.Service do
  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.Agency

  schema "services" do
    belongs_to(:agency, Agency)
    field(:end_date, :date)
    field(:friday, :boolean, default: false)
    field(:monday, :boolean, default: false)
    field(:remote_id, :string)
    field(:saturday, :boolean, default: false)
    field(:start_date, :date)
    field(:sunday, :boolean, default: false)
    field(:thursday, :boolean, default: false)
    field(:tuesday, :boolean, default: false)
    field(:wednesday, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [
      :agency_id,
      :remote_id,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
      :start_date,
      :end_date
    ])
    |> validate_required([
      :agency_id,
      :remote_id,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
      :start_date,
      :end_date
    ])
  end
end
