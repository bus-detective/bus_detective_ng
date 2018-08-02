defmodule Importer.GTFSImport do
  @moduledoc """
  This context module has functions used only by the `Importer`
  """

  import Ecto.Query, warn: false

  require Logger

  alias BusDetective.GTFS.{
    Agency,
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

  def add_projected_stop_times_for_service_date(service_id, agency_id, start_of_day) do
    query = """
    INSERT INTO projected_stop_times
    (
      "stop_time_id",
      "scheduled_arrival_time",
      "scheduled_departure_time",
      "inserted_at",
      "updated_at"
    )
    (
      SELECT s0."id",
             ($1 AT TIME ZONE 'UTC' + s0."arrival_time"),
             ($2 AT TIME ZONE 'UTC' + s0."departure_time"),
             now(),
             now()
      FROM "stop_times" AS s0
      INNER JOIN "trips" AS t1 ON t1."id" = s0."trip_id"
      INNER JOIN "routes" AS r2 ON r2."id" = t1."route_id"
      WHERE r2."agency_id" = $3 AND t1."service_id" = $4
    )
    ON CONFLICT (stop_time_id, scheduled_arrival_time, scheduled_departure_time)
    DO NOTHING
    RETURNING id
    """

    Repo.query(query, [start_of_day, start_of_day, agency_id, service_id], timeout: 60_000)
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

  def bulk_create_service_exceptions(service_exceptions) do
    Repo.insert_all(ServiceException, service_exceptions, returning: [:id])
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

  def bulk_create_stop_times(stop_times) do
    Repo.insert_all(StopTime, stop_times, returning: [:id], timeout: 60_000)
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
            location: fragment("EXCLUDED.location"),
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
  Creates a agency.
  """
  def create_agency(attrs \\ %{}) do
    %Agency{}
    |> Agency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a feed.
  """
  def create_feed(attrs \\ %{}) do
    %Feed{}
    |> Feed.changeset(attrs)
    |> Repo.insert()
  end

  def delete_old_projected_stop_times(delete_before_date) do
    date = Timex.to_datetime(delete_before_date)

    Repo.delete_all(
      from(
        pst in ProjectedStopTime,
        where: pst.scheduled_departure_time < ^date
      ),
      timeout: 60_000
    )
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

  def get_feed_by_name(name) do
    Repo.one(
      from(
        feed in Feed,
        where: feed.name == ^name,
        preload: :agencies
      )
    )
  end

  def preload_agencies(feed) do
    Repo.preload(feed, :agencies, force: true)
  end

  def get_service_exceptions(feed_id, start_date, end_date) do
    Repo.all(
      from(
        service_exception in ServiceException,
        where: service_exception.date >= ^start_date,
        where: service_exception.date <= ^end_date,
        where: service_exception.feed_id == ^feed_id,
        preload: [:service]
      )
    )
  end

  def get_services(feed_id) do
    Repo.all(
      from(
        service in Service,
        where: service.feed_id == ^feed_id
      )
    )
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
  Updates a feed.
  """
  def update_feed(%Feed{} = feed, attrs) do
    feed
    |> Feed.changeset(attrs)
    |> Repo.update()
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
end
