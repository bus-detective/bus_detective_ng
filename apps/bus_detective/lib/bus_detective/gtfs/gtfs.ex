defmodule BusDetective.GTFS do
  @moduledoc """
  The GTFS context.
  """

  import Ecto.Query, warn: false

  alias BusDetective.GTFS.{
    Agency,
    Departure,
    Feed,
    ProjectedStopTime,
    Route,
    RouteStop,
    Service,
    ServiceException,
    Shape,
    Stop,
    StopTime,
    Trip
  }

  alias BusDetective.Repo
  alias Ecto.Adapters.SQL
  alias Realtime.{StopTimeUpdate, TripUpdates}

  def departures_for_stop(stop, start_time, end_time) do
    stop
    |> projected_stop_times_for_stop(start_time, end_time)
    |> Enum.map(fn projected_stop_time ->
      %ProjectedStopTime{
        stop_time: %StopTime{trip: %Trip{block_id: block_id, remote_id: trip_remote_id}, stop_sequence: stop_sequence}
      } = projected_stop_time

      case TripUpdates.find_stop_time(block_id, trip_remote_id, stop_sequence, &fetch_related_trips/1) do
        {:ok, %StopTimeUpdate{} = stop_time_update} ->
          %Departure{
            scheduled_time: projected_stop_time.scheduled_departure_time,
            time: stop_time_update.departure_time,
            realtime?: true,
            delay: stop_time_update.delay,
            trip: projected_stop_time.stop_time.trip,
            route: projected_stop_time.stop_time.trip.route,
            agency: projected_stop_time.stop_time.trip.route.agency
          }

        _ ->
          %Departure{
            scheduled_time: projected_stop_time.scheduled_departure_time,
            time: projected_stop_time.scheduled_departure_time,
            realtime?: false,
            delay: 0,
            trip: projected_stop_time.stop_time.trip,
            route: projected_stop_time.stop_time.trip.route,
            agency: projected_stop_time.stop_time.trip.route.agency
          }
      end
    end)
    |> Enum.sort_by(&Timex.to_erl(&1.time))
  end

  def fetch_related_trips(block_id) do
    Repo.all(
      from(
        trip in Trip,
        where: trip.block_id == ^block_id,
        select: trip.remote_id
      )
    )
  end

  def projected_stop_times_for_stop(%Stop{id: stop_id}, %DateTime{} = start_time, %DateTime{} = end_time) do
    Repo.all(
      from(
        projected in ProjectedStopTime,
        join: stop_time in assoc(projected, :stop_time),
        where: stop_time.stop_id == ^stop_id,
        where: projected.scheduled_departure_time >= ^start_time,
        where: projected.scheduled_departure_time <= ^end_time,
        order_by: [:scheduled_departure_time],
        preload: [stop_time: [trip: [:shape, route: :agency]]]
      )
    )
  end

  @doc """
  Gets an agency by its remote id
  """
  def get_agency_by_remote_id(feed_id, remote_id) do
    Repo.one(
      from(
        a in Agency,
        where: a.feed_id == ^feed_id,
        where: a.remote_id == ^remote_id
      )
    )
  end

  @doc """
  returns the list of feeds.
  """
  def list_feeds do
    Repo.all(Feed)
  end

  @doc """
  returns the list of agencies.
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
  Updates an agency.
  """
  def update_agency(%Agency{} = agency, attrs \\ %{}) do
    agency
    |> Agency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes all service exceptions for a feed
  """
  def destroy_service_exceptions_for_feed(%Feed{id: feed_id}) do
    Repo.delete_all(
      from(
        service_exception in ServiceException,
        where: service_exception.feed_id == ^feed_id
      ),
      timeout: 60_000
    )
  end

  @doc """
  Deletes all stop times (and associated projected stop times) for a feed
  """
  def destroy_stop_times_for_feed(%Feed{id: feed_id}) do
    Repo.delete_all(
      from(
        stop_time in StopTime,
        where: stop_time.feed_id == ^feed_id
      ),
      timeout: 60_000
    )
  end

  @doc """
  Deletes all calculated route stops for a feed
  """
  def destroy_route_stops_for_feed(%Feed{id: feed_id}) do
    Repo.delete_all(
      from(
        route_stop in RouteStop,
        join: route in assoc(route_stop, :route),
        where: route.feed_id == ^feed_id
      ),
      timeout: 60_000
    )
  end

  @doc """
  Returns the list of services.
  """
  def list_services(%Feed{id: feed_id}) do
    Repo.all(from(service in Service, where: service.feed_id == ^feed_id))
  end

  @doc """
  Gets a single service by feed and remote_id.

  Returns nil if no matching service exists
  """
  def get_service(%Feed{id: feed_id}, remote_id) do
    Repo.one(from(service in Service, where: service.feed_id == ^feed_id and service.remote_id == ^remote_id))
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
    on_conflict_query =
      from(
        service in Service,
        update: [
          set: [
            monday: fragment("EXCLUDED.monday"),
            tuesday: fragment("EXCLUDED.tuesday"),
            wednesday: fragment("EXCLUDED.wednesday"),
            thursday: fragment("EXCLUDED.thursday"),
            friday: fragment("EXCLUDED.friday"),
            saturday: fragment("EXCLUDED.saturday"),
            sunday: fragment("EXCLUDED.sunday"),
            start_date: fragment("EXCLUDED.start_date"),
            end_date: fragment("EXCLUDED.end_date"),
            updated_at: fragment("EXCLUDED.updated_at")
          ]
        ]
      )

    Repo.insert_all(
      Service,
      services,
      conflict_target: [:feed_id, :remote_id],
      on_conflict: on_conflict_query,
      returning: [:id, :remote_id, :feed_id]
    )
  end

  @doc """
  Returns the list of service_exceptions.
  """
  def list_service_exceptions(%Feed{id: feed_id}, %Service{id: service_id}) do
    Repo.all(from(se in ServiceException, where: se.feed_id == ^feed_id and se.service_id == ^service_id))
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
  def list_routes(%Feed{id: feed_id}) do
    Repo.all(from(r in Route, where: r.feed_id == ^feed_id))
  end

  @doc """
  Gets a single route.

  Returns nil if no results found
  """
  def get_route(%Feed{id: feed_id}, remote_id) do
    Repo.one(from(r in Route, where: r.feed_id == ^feed_id and r.remote_id == ^remote_id))
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
    on_conflict_query =
      from(
        route in Route,
        update: [
          set: [
            short_name: fragment("EXCLUDED.short_name"),
            long_name: fragment("EXCLUDED.long_name"),
            description: fragment("EXCLUDED.description"),
            route_type: fragment("EXCLUDED.route_type"),
            url: fragment("EXCLUDED.url"),
            color: fragment("EXCLUDED.color"),
            text_color: fragment("EXCLUDED.text_color"),
            updated_at: fragment("EXCLUDED.updated_at")
          ]
        ]
      )

    Repo.insert_all(
      Route,
      routes,
      conflict_target: [:feed_id, :remote_id],
      on_conflict: on_conflict_query,
      returning: [:id, :remote_id, :feed_id]
    )
  end

  @doc """
  Returns the list of stops.

  Returns nil if no results found
  """
  def list_stops(%Feed{id: feed_id}) do
    Repo.all(from(s in Stop, where: s.feed_id == ^feed_id))
  end

  def search_stops(options) do
    query = Keyword.get(options, :query)
    pagination_options = options

    Repo.paginate(
      from(
        s in Stop,
        where: fragment("? ILIKE ?", s.name, ^"%#{query}%"),
        preload: [:routes, :feed]
      ),
      pagination_options
    )
  end

  @doc """
  Gets a single stop.

  Returns nil if no results found
  """
  def get_stop(%Feed{id: feed_id}, remote_id) do
    Repo.one(from(s in Stop, where: s.feed_id == ^feed_id and s.remote_id == ^remote_id))
  end

  def get_stop!(id) do
    Stop
    |> Repo.get!(id)
    |> Repo.preload([:feed, :routes])
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
    on_conflict_query =
      from(
        stop in Stop,
        update: [
          set: [
            code: fragment("EXCLUDED.code"),
            name: fragment("EXCLUDED.name"),
            description: fragment("EXCLUDED.description"),
            latitude: fragment("EXCLUDED.latitude"),
            longitude: fragment("EXCLUDED.longitude"),
            zone_id: fragment("EXCLUDED.zone_id"),
            url: fragment("EXCLUDED.url"),
            location_type: fragment("EXCLUDED.location_type"),
            parent_station: fragment("EXCLUDED.parent_station"),
            timezone: fragment("EXCLUDED.timezone"),
            wheelchair_boarding: fragment("EXCLUDED.wheelchair_boarding"),
            updated_at: fragment("EXCLUDED.updated_at")
          ]
        ]
      )

    Repo.insert_all(
      Stop,
      stops,
      conflict_target: [:feed_id, :remote_id],
      on_conflict: on_conflict_query,
      returning: [:id, :remote_id, :feed_id]
    )
  end

  @doc """
  Returns the list of shapes.
  """
  def list_shapes(%Feed{id: feed_id}) do
    Repo.all(from(s in Shape, where: s.feed_id == ^feed_id))
  end

  @doc """
  Gets a single shape.

  Returns nil if no results found
  """
  def get_shape(%Feed{id: feed_id}, remote_id) do
    Repo.one(from(s in Shape, where: s.feed_id == ^feed_id and s.remote_id == ^remote_id))
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
    on_conflict_query =
      from(
        shape in Shape,
        update: [
          set: [
            geometry: fragment("EXCLUDED.geometry"),
            updated_at: fragment("EXCLUDED.updated_at")
          ]
        ]
      )

    Repo.insert_all(
      Shape,
      shapes,
      conflict_target: [:feed_id, :remote_id],
      on_conflict: on_conflict_query,
      returning: [:id, :remote_id, :feed_id]
    )
  end

  @doc """
  Returns the list of trips.
  """
  def list_trips(%Feed{id: feed_id}) do
    Repo.all(from(t in Trip, where: t.feed_id == ^feed_id))
  end

  @doc """
  Gets a single trip.

  Returns nil if no results found
  """
  def get_trip(%Feed{id: feed_id}, remote_id) do
    Repo.one(from(t in Trip, where: t.feed_id == ^feed_id and t.remote_id == ^remote_id))
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
  Gets trips with the given block_id
  """
  def get_trips_in_block(block_id) do
    Repo.all(
      from(
        trip in Trip,
        where: trip.block_id == ^block_id
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
    on_conflict_query =
      from(
        trip in Trip,
        update: [
          set: [
            route_id: fragment("EXCLUDED.route_id"),
            service_id: fragment("EXCLUDED.service_id"),
            shape_id: fragment("EXCLUDED.shape_id"),
            headsign: fragment("EXCLUDED.headsign"),
            short_name: fragment("EXCLUDED.short_name"),
            direction_id: fragment("EXCLUDED.direction_id"),
            block_id: fragment("EXCLUDED.block_id"),
            wheelchair_accessible: fragment("EXCLUDED.wheelchair_accessible"),
            bikes_allowed: fragment("EXCLUDED.bikes_allowed"),
            updated_at: fragment("EXCLUDED.updated_at")
          ]
        ]
      )

    Repo.insert_all(
      Trip,
      trips,
      conflict_target: [:feed_id, :remote_id],
      on_conflict: on_conflict_query,
      returning: [:id, :feed_id, :remote_id]
    )
  end

  @doc """
  Returns the list of stop_times.
  """
  def list_stop_times(%Feed{id: feed_id}) do
    Repo.all(from(st in StopTime, where: st.feed_id == ^feed_id))
  end

  @doc """
  Gets a single stop_time.

  Returns nil if no results found
  """
  def get_stop_time(%Feed{id: feed_id}, %Stop{id: stop_id}, stop_sequence, %Trip{id: trip_id}) do
    Repo.one(
      from(
        st in StopTime,
        where:
          st.feed_id == ^feed_id and st.trip_id == ^trip_id and st.stop_id == ^stop_id and
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

  def bulk_create_projected_stop_times(projected_stop_times) do
    Repo.insert_all(ProjectedStopTime, projected_stop_times, returning: [:id], timeout: 60_000)
  end

  def update_route_stops(%Feed{id: feed_id}) do
    {:ok, _} =
      SQL.query(
        Repo,
        """
        INSERT INTO routes_stops (route_id, stop_id)
        SELECT DISTINCT routes.id as route_id, stops.id as stop_id
        FROM routes
        INNER JOIN trips ON trips.route_id = routes.id
        INNER JOIN stop_times ON stop_times.trip_id = trips.id
        INNER JOIN stops ON stops.id = stop_times.stop_id
        WHERE routes.feed_id = $1
        """,
        [feed_id]
      )
  end

  @doc """
  Creates a feed.

  ## Examples

      iex> create_feed(%{field: value})
      {:ok, %Feed{}}

      iex> create_feed(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feed(attrs \\ %{}) do
    %Feed{}
    |> Feed.changeset(attrs)
    |> Repo.insert()
  end

  def get_feed_by_name(name) do
    Repo.one(
      from(
        feed in Feed,
        where: feed.name == ^name
      )
    )
  end

  @doc """
  Updates a feed.

  ## Examples

      iex> update_feed(feed, %{field: new_value})
      {:ok, %Feed{}}

      iex> update_feed(feed, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feed(%Feed{} = feed, attrs) do
    feed
    |> Feed.changeset(attrs)
    |> Repo.update()
  end
end
