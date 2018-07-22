defmodule BusDetective.GTFS.Service do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, ServiceException, Trip}

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

    has_many(:service_exceptions, ServiceException, on_delete: :delete_all)
    has_many(:trips, Trip, on_delete: :delete_all)

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
    |> unique_constraint(:remote_id, name: :services_agency_id_remote_id_index)
  end

  def weekday_schedule(%__MODULE__{} = service) do
    %{
      "Sunday" => service.sunday,
      "Monday" => service.monday,
      "Tuesday" => service.tuesday,
      "Wednesday" => service.wednesday,
      "Thursday" => service.thursday,
      "Friday" => service.friday,
      "Saturday" => service.saturday
    }
  end
end
