defmodule BusDetective.GTFS.Stop do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, RouteStop, StopTime}

  @direction_labels %{
    "i" => "inbound",
    "o" => "outbound",
    "n" => "northbound",
    "s" => "southbound",
    "e" => "eastbound",
    "w" => "westbound"
  }

  schema "stops" do
    belongs_to(:agency, Agency)
    field(:code, :integer)
    field(:description, :string)
    field(:latitude, :float)
    field(:location_type, :integer)
    field(:longitude, :float)
    field(:name, :string)
    field(:parent_station, :string)
    field(:remote_id, :string)
    field(:timezone, :string)
    field(:url, :string)
    field(:wheelchair_boarding, :integer)
    field(:zone_id, :integer)

    has_many(:stop_routes, RouteStop, on_delete: :delete_all)
    has_many(:routes, through: [:stop_routes, :route])
    has_many(:stop_times, StopTime, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(stop, attrs) do
    stop
    |> cast(attrs, [
      :agency_id,
      :remote_id,
      :code,
      :name,
      :description,
      :latitude,
      :longitude,
      :zone_id,
      :url,
      :location_type,
      :parent_station,
      :timezone,
      :wheelchair_boarding
    ])
    |> validate_required([
      :agency_id,
      :remote_id,
      :name,
      :latitude,
      :longitude
    ])
  end

  def direction(%__MODULE__{remote_id: remote_id}) do
    Map.get(@direction_labels, String.last(remote_id), "")
  end
end
