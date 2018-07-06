defmodule BusDetective.GTFS.Shape do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.Agency

  schema "shapes" do
    belongs_to(:agency, Agency)
    field(:geometry, Geo.PostGIS.Geometry)
    field(:remote_id, :string)

    timestamps()
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:agency_id, :remote_id, :geometry])
    |> validate_required([:agency_id, :remote_id, :geometry])
  end
end
