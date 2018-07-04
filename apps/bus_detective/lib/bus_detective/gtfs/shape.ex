defmodule BusDetective.GTFS.Shape do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shapes" do
    field(:agency_id, :integer)
    field(:geometry, :string)
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
