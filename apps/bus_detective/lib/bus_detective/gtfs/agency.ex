defmodule BusDetective.GTFS.Agency do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Route, Service, Shape}

  schema "agencies" do
    field(:display_name, :string)
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

    has_many(:routes, Route, on_delete: :delete_all)
    has_many(:services, Service, on_delete: :delete_all)
    has_many(:shapes, Shape, on_delete: :delete_all)

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
    |> validate_required([:name, :url, :timezone])
    |> unique_constraint(:remote_id, name: :agencies_remote_id_index)
  end
end
