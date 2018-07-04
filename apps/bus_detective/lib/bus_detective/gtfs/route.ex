defmodule BusDetective.GTFS.Route do
  use Ecto.Schema
  import Ecto.Changeset

  schema "routes" do
    field(:agency_id, :integer)
    field(:color, :string)
    field(:description, :string)
    field(:long_name, :string)
    field(:remote_id, :string)
    field(:route_type, :string)
    field(:short_name, :string)
    field(:text_color, :string)
    field(:url, :string)

    timestamps()
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [
      :agency_id,
      :remote_id,
      :short_name,
      :long_name,
      :description,
      :route_type,
      :url,
      :color,
      :text_color
    ])
    |> validate_required([
      :agency_id,
      :remote_id,
      :short_name,
      :long_name,
      :description,
      :route_type,
      :url,
      :color,
      :text_color
    ])
  end
end
