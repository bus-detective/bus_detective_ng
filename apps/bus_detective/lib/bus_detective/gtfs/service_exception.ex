defmodule BusDetective.GTFS.ServiceException do
  use Ecto.Schema
  import Ecto.Changeset


  schema "service_exceptions" do
    field :agency_id, :integer
    field :date, :date
    field :exception, :integer
    field :service_id, :integer

    timestamps()
  end

  @doc false
  def changeset(service_exception, attrs) do
    service_exception
    |> cast(attrs, [:agency_id, :service_id, :date, :exception])
    |> validate_required([:agency_id, :service_id, :date, :exception])
  end
end
