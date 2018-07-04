defmodule BusDetective.GTFS.Agency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agencies" do
    field(:fare_url, :string)
    field(:gtfs_endpoint, :string)
    field(:gtfs_service_alerts_url, :string)
    field(:gtfs_trip_updates_url, :string)
    field(:gtfs_vehicle_positions_url, :string)
    field(:language, :string)
    field(:name, :string)
    field(:phone, :string)
    field(:remote_id, :string)
    field(:timezone, :string)
    field(:url, :string)

    timestamps()
  end

  @doc false
  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [
      :remote_id,
      :name,
      :url,
      :fare_url,
      :timezone,
      :language,
      :phone,
      :gtfs_endpoint,
      :gtfs_trip_updates_url,
      :gtfs_vehicle_positions_url,
      :gtfs_service_alerts_url
    ])
  end
end
