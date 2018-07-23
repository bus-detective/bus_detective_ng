defmodule BusDetective.GTFS.Feed do
  @moduledoc """
  Module/struct relating to an import of schedule GTFS data containing one or
  more agencies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Agency, Service, Shape}

  schema "feeds" do
    field(:last_file_hash, :string)
    field(:last_updated, :utc_datetime)
    field(:name, :string)

    has_many(:agencies, Agency, on_delete: :delete_all)
    has_many(:services, Service, on_delete: :delete_all)
    has_many(:shapes, Shape, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:last_updated, :last_file_hash, :name])
    |> validate_required([:name])
  end
end
