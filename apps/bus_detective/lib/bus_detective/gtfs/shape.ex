defmodule BusDetective.GTFS.Shape do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Feed, Shape, Trip}

  schema "shapes" do
    belongs_to(:feed, Feed)

    field(:geometry, Geo.PostGIS.Geometry)
    field(:remote_id, :string)

    has_many(:trips, Trip, on_delete: :nilify_all)

    timestamps()
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:feed_id, :remote_id, :geometry])
    |> validate_required([:feed_id, :remote_id, :geometry])
    |> unique_constraint(:remote_id, name: :shapes_feed_id_remote_id_index)
  end

  def coordinates_to_map(%Shape{geometry: %{coordinates: coordinates}}) do
    Enum.map(coordinates, fn {latitude, longitude} -> [latitude, longitude] end)
  end

  def coordinates_to_map(_), do: nil
end
