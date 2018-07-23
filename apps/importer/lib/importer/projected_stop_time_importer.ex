defmodule Importer.ProjectedStopTimeImporter do
  @moduledoc """
  This module handles the projection of planned stop times out into actual stops
  and times on specific service dates.
  """

  require Logger

  import Ecto.Query

  alias BusDetective.GTFS.{Agency, Feed, Service, ServiceException}
  alias BusDetective.Repo
  alias Timex.Timezone
  alias Timex.Interval, as: TimexInterval

  def project_stop_times(feed_or_agency, opts \\ [])

  def project_stop_times(%Feed{} = feed, opts) do
    feed = Repo.preload(feed, :agencies)
    feed.agencies
    |> Enum.each(fn(agency) -> project_stop_times(agency, opts) end)
  end

  def project_stop_times(%Agency{id: agency_id, feed_id: feed_id, timezone: tz, remote_id: remote_id}, opts) do
    Logger.info("Projecting stop times")
    timezone = Timezone.get(tz)

    services =
      Repo.all(
        from(
          service in Service,
          where: service.feed_id == ^feed_id
        )
      )

    start_date = Keyword.get(opts, :start_date, Timex.now() |> Timex.shift(days: -1) |> Timex.to_date())
    end_date = Keyword.get(opts, :end_date, Timex.now() |> Timex.shift(days: 2) |> Timex.to_date())

    service_exceptions =
      Repo.all(
        from(
          service_exception in ServiceException,
          where: service_exception.date >= ^start_date,
          where: service_exception.date <= ^end_date,
          where: service_exception.feed_id == ^feed_id,
          preload: [:service]
        )
      )

    for date <- %TimexInterval{from: start_date, until: end_date} do
      for service_id <- active_service_ids(date, services, service_exceptions) do
        start_of_day = start_of_agency_day_utc(date, timezone)
        Logger.debug(fn -> "Adding projected stop times for agency: #{remote_id}, for service: #{service_id} on #{date}" end)
        {:ok, %{num_rows: num_rows}} = add_projected_stop_times_for_service_date(service_id, agency_id, start_of_day)
        Logger.debug(fn -> "Added #{num_rows}" end)
      end
    end
  end

  defp add_projected_stop_times_for_service_date(service_id, agency_id, start_of_day) do
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
    RETURNING id
    """

    Repo.query(query, [start_of_day, start_of_day, agency_id, service_id], timeout: 60_000)
  end

  @addition 1
  @removal 2
  defp active_service_ids(date, services, service_exceptions) do
    weekday_name = date |> Timex.format!("{WDfull}")

    services
    |> Enum.filter(fn service ->
      regular_service? = Service.weekday_schedule(service)[weekday_name]

      service_removals =
        service_exceptions
        |> Enum.filter(fn exception ->
          exception.date == date && exception.exception == @removal && exception.service_id == service.id
        end)

      service_additions =
        service_exceptions
        |> Enum.filter(fn exception ->
          exception.date == date && exception.exception == @addition && exception.service_id == service.id
        end)

      (Enum.empty?(service_removals) && regular_service?) || Enum.count(service_additions) > 0
    end)
    |> Enum.map(&(&1.id))
  end

  def start_of_agency_day_utc(date, agency_timezone) do
    case NaiveDateTime.new(date, ~T[12:00:00]) do
      {:ok, naive_noon} ->
        naive_noon
        |> Timex.to_datetime(agency_timezone)
        |> Timex.shift(hours: -12)
        |> Timezone.convert(:utc)

      error ->
        error
    end
  end
end
