defmodule BusDetective.GTFS.Stop do
  use Ecto.Schema
  import Ecto.Changeset


  schema "stops" do
    field :agency_id, :integer
    field :code, :integer
    field :description, :string
    field :latitude, :float
    field :location_type, :integer
    field :longitude, :float
    field :name, :string
    field :parent_station, :string
    field :remote_id, :string
    field :timezone, :string
    field :url, :string
    field :wheelchair_boarding, :integer
    field :zone_id, :integer

    timestamps()
  end

  @doc false
  def changeset(stop, attrs) do
    stop
    |> cast(attrs, [:agency_id, :remote_id, :code, :name, :description, :latitude, :longitude, :zone_id, :url, :location_type, :parent_station, :timezone, :wheelchair_boarding])
    |> validate_required([:agency_id, :remote_id, :code, :name, :description, :latitude, :longitude, :zone_id, :url, :location_type, :parent_station, :timezone, :wheelchair_boarding])
  end
end
