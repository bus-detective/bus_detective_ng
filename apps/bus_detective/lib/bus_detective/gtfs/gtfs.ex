defmodule BusDetective.GTFS do
  @moduledoc """
  The GTFS context.
  """

  import Ecto.Query, warn: false
  alias BusDetective.Repo

  alias BusDetective.GTFS.{Agency, Route, Service, ServiceException, Shape, Stop, StopTime, Trip}

  @doc """
  Returns the list of agencies.
  """
  def list_agencies do
    Repo.all(Agency)
  end

  @doc """
  Creates a agency.
  """
  def create_agency(attrs \\ %{}) do
    %Agency{}
    |> Agency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of services.
  """
  def list_services(%Agency{id: agency_id}) do
    Repo.all(from(service in Service, where: service.agency_id == ^agency_id))
  end

  @doc """
  Gets a single service by agency and remote_id.

  Returns nil if no matching service exists
  """
  def get_service(%Agency{id: agency_id}, remote_id) do
    Repo.one(from(service in Service, where: service.agency_id == ^agency_id and service.remote_id == ^remote_id))
  end

  @doc """
  Creates a service.
  """
  def create_service(attrs \\ %{}) do
    %Service{}
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_services(services) do
    Repo.insert_all(Service, services, returning: [:id, :remote_id, :agency_id])
  end

  @doc """
  Returns the list of service_exceptions.
  """
  def list_service_exceptions(%Agency{id: agency_id}, %Service{id: service_id}) do
    Repo.all(from(se in ServiceException, where: se.agency_id == ^agency_id and se.service_id == ^service_id))
  end

  @doc """
  Gets a single service_exception.

  Raises `Ecto.NoResultsError` if the Service exception does not exist.
  """
  def get_service_exception!(id), do: Repo.get!(ServiceException, id)

  @doc """
  Creates a service_exception.
  """
  def create_service_exception(attrs \\ %{}) do
    %ServiceException{}
    |> ServiceException.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_service_exceptions(service_exceptions) do
    Repo.insert_all(ServiceException, service_exceptions, returning: [:id])
  end

  @doc """
  Returns the list of routes.
  """
  def list_routes(%Agency{id: agency_id}) do
    Repo.all(from(r in Route, where: r.agency_id == ^agency_id))
  end

  @doc """
  Gets a single route.

  Returns nil if no results found
  """
  def get_route(%Agency{id: agency_id}, remote_id) do
    Repo.one(from(r in Route, where: r.agency_id == ^agency_id and r.remote_id == ^remote_id))
  end

  @doc """
  Creates a route.
  """
  def create_route(attrs \\ %{}) do
    %Route{}
    |> Route.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_routes(routes) do
    Repo.insert_all(Route, routes, returning: [:id, :remote_id, :agency_id])
  end

  @doc """
  Returns the list of stops.

  Returns nil if no results found
  """
  def list_stops(%Agency{id: agency_id}) do
    Repo.all(from(s in Stop, where: s.agency_id == ^agency_id))
  end

  @doc """
  Gets a single stop.

  Returns nil if no results found
  """
  def get_stop(%Agency{id: agency_id}, remote_id) do
    Repo.one(from(s in Stop, where: s.agency_id == ^agency_id and s.remote_id == ^remote_id))
  end

  @doc """
  Creates a stop.
  """
  def create_stop(attrs \\ %{}) do
    %Stop{}
    |> Stop.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_stops(stops) do
    Repo.insert_all(Stop, stops, returning: [:id, :remote_id, :agency_id])
  end

  @doc """
  Returns the list of shapes.
  """
  def list_shapes(%Agency{id: agency_id}) do
    Repo.all(from(s in Shape, where: s.agency_id == ^agency_id))
  end

  @doc """
  Gets a single shape.

  Returns nil if no results found
  """
  def get_shape(%Agency{id: agency_id}, remote_id) do
    Repo.one(from(s in Shape, where: s.agency_id == ^agency_id and s.remote_id == ^remote_id))
  end

  @doc """
  Creates a shape.
  """
  def create_shape(attrs \\ %{}) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_shapes(shapes) do
    Repo.insert_all(Shape, shapes, returning: [:id, :remote_id, :agency_id])
  end

  @doc """
  Returns the list of trips.
  """
  def list_trips(%Agency{id: agency_id}) do
    Repo.all(from(t in Trip, where: t.agency_id == ^agency_id))
  end

  @doc """
  Gets a single trip.

  Returns nil if no results found
  """
  def get_trip(%Agency{id: agency_id}, remote_id) do
    Repo.one(from(t in Trip, where: t.agency_id == ^agency_id and t.remote_id == ^remote_id))
  end

  @doc """
  Creates a trip.
  """
  def create_trip(attrs \\ %{}) do
    %Trip{}
    |> Trip.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_trips(trips) do
    Repo.insert_all(Trip, trips, returning: [:id, :agency_id, :remote_id])
  end

  @doc """
  Returns the list of stop_times.
  """
  def list_stop_times(%Agency{id: agency_id}) do
    Repo.all(from(st in StopTime, where: st.agency_id == ^agency_id))
  end

  @doc """
  Gets a single stop_time.

  Returns nil if no results found
  """
  def get_stop_time(%Agency{id: agency_id}, %Stop{id: stop_id}, stop_sequence, %Trip{id: trip_id}) do
    Repo.one(
      from(
        st in StopTime,
        where:
          st.agency_id == ^agency_id and st.trip_id == ^trip_id and st.stop_id == ^stop_id and
            st.stop_sequence == ^stop_sequence
      )
    )
  end

  @doc """
  Creates a stop_time.
  """
  def create_stop_time(attrs \\ %{}) do
    %StopTime{}
    |> StopTime.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create_stop_times(stop_times) do
    Repo.insert_all(StopTime, stop_times, returning: true)
  end
end
