defmodule BusDetective.GTFS.Agency do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Feed, Route}

  schema "agencies" do
    belongs_to(:feed, Feed)

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

    timestamps()
  end

  @doc false
  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [
      :feed_id,
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
    |> validate_required([:feed_id, :name, :url, :timezone])
    |> unique_constraint(:remote_id, name: :agencies_feed_id_remote_id_index)
  end
end
