defmodule BusDetective.GTFS do
  @moduledoc """
  The GTFS context.
  """

  import Ecto.Query, warn: false

  alias BusDetective.GTFS.{Agency, Route, Service, ServiceException, Shape, Stop, StopTime, Trip}
  alias BusDetective.Repo
  alias Ecto.Adapters.SQL
  alias Timex.Timezone

  @doc """
  This is the trickiest of functions in the application. It uses some stored
  procedures and all the SQL shenanigans you see here to calculate actual
  scheduled stop times from the schedule data.

  This function expects the start and end times to be specified in the
  timezone of the agency. That ensures that `start_date` and `end_date` use
  the day boundaries with the agency timezone instead of utc boundaries,
  which could throw the data off around midnight.
  """
  def calculated_stop_times_between(%Stop{id: stop_id}, %DateTime{} = start_time, %DateTime{} = end_time) do
    start_date = Timex.to_date(start_time)
    end_date = Timex.to_date(end_time)

    utc_start_time = Timezone.convert(start_time, :utc)
    utc_end_time = Timezone.convert(end_time, :utc)

    Repo.all(
      from(
        st in StopTime,
        join: agency in assoc(st, :agency),
        join: trip in assoc(st, :trip),
        join:
          effective_service in fragment(
            "SELECT * FROM effective_services(?, ?)",
            ^start_date,
            ^end_date
          ),
        on: trip.service_id == effective_service.service_id,
        where: st.stop_id == ^stop_id,
        where:
          fragment(
            "(start_time(?) + ?) BETWEEN (? AT TIME ZONE ?) AND (? AT TIME ZONE ?)",
            effective_service.date,
            st.departure_time,
            ^utc_start_time,
            agency.timezone,
            ^utc_end_time,
            agency.timezone
          ),
        order_by:
          fragment(
            "start_time(?) + ?",
            effective_service.date,
            st.departure_time
          ),
        select_merge: %{
          calculated_arrival_time:
            fragment(
              "((start_time(?) + ?) AT TIME ZONE ?) AS calculated_arrival_time",
              effective_service.date,
              st.arrival_time,
              agency.timezone
            ),
          calculated_departure_time:
            fragment(
              "((start_time(?) + ?) AT TIME ZONE ?) AS calculated_departure_time",
              effective_service.date,
              st.departure_time,
              agency.timezone
            )
        },
        preload: [trip: :route]
      )
    )
  end

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
  Deletes an agency by remote_id and all the related associations
  """
  def destroy(remote_id) do
    agency =
      Repo.one(
        from(
          agency in Agency,
          where: agency.remote_id == ^remote_id
        )
      )

    if agency do
      Repo.delete(agency)
    end
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

  def search_stops(options) do
    query = Keyword.get(options, :query)
    pagination_options = options

    Repo.paginate(
      from(
        s in Stop,
        where: fragment("? ILIKE ?", s.name, ^"%#{query}%"),
        preload: [:routes, :agency]
      ),
      pagination_options
    )
  end

  @doc """
  Gets a single stop.

  Returns nil if no results found
  """
  def get_stop(%Agency{id: agency_id}, remote_id) do
    Repo.one(from(s in Stop, where: s.agency_id == ^agency_id and s.remote_id == ^remote_id))
  end

  def get_stop!(id) do
    Stop
    |> Repo.get!(id)
    |> Repo.preload([:agency, :routes])
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

  def get_trips(ids) do
    Repo.all(
      from(
        trip in Trip,
        where: trip.id in ^ids,
        preload: [:route, :shape]
      )
    )
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

  def update_route_stops do
    {:ok, _} = SQL.query(Repo, "TRUNCATE TABLE routes_stops", [])

    {:ok, _} =
      SQL.query(
        Repo,
        """
        INSERT INTO routes_stops (route_id, stop_id)
        SELECT DISTINCT
        routes.id as route_id, stops.id as stop_id
        FROM
        routes
        INNER JOIN
        trips ON trips.route_id = routes.id
        INNER JOIN
        stop_times ON stop_times.trip_id = trips.id
        INNER JOIN
        stops ON stops.id = stop_times.stop_id
        """,
        []
      )
  end
end
