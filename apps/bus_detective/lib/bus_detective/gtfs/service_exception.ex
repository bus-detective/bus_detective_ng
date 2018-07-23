defmodule BusDetective.GTFS.ServiceException do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BusDetective.GTFS.{Feed, Service}

  schema "service_exceptions" do
    belongs_to(:feed, Feed)
    belongs_to(:service, Service)

    field(:date, :date)
    field(:exception, :integer)

    timestamps()
  end

  @doc false
  def changeset(service_exception, attrs) do
    service_exception
    |> cast(attrs, [:feed_id, :service_id, :date, :exception])
    |> validate_required([:feed_id, :service_id, :date, :exception])
  end
end
