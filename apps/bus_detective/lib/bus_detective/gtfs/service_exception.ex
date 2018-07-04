defmodule BusDetective.GTFS.ServiceException do
  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, Service}

  schema "service_exceptions" do
    belongs_to(:agency, Agency)
    belongs_to(:service, Service)
    field(:date, :date)
    field(:exception, :integer)

    timestamps()
  end

  @doc false
  def changeset(service_exception, attrs) do
    service_exception
    |> cast(attrs, [:agency_id, :service_id, :date, :exception])
    |> validate_required([:agency_id, :service_id, :date, :exception])
  end
end
