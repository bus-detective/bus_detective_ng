defmodule Importer.ProjectedStopTimeImporter do
  @moduledoc """
  This module handles the projection of planned stop times out into actual stops
  and times on specific service dates.
  """

  require Logger

  alias BusDetective.GTFS.{Agency, Feed, Service}
  alias Importer.GTFSImport
  alias Timex.Timezone
  alias Timex.Interval, as: TimexInterval

  @service_addition 1
  @service_removal 2

  def project_stop_times(feed_or_agency, opts \\ [])

  def project_stop_times(%Feed{} = feed, opts) do
    feed.agencies
    |> Enum.each(fn agency -> project_stop_times(agency, opts) end)
  end

  def project_stop_times(%Agency{id: agency_id, feed_id: feed_id, timezone: tz, remote_id: remote_id}, opts) do
    Logger.info("Projecting stop times")
    timezone = Timezone.get(tz)

    start_date = Keyword.get(opts, :start_date, Timex.now() |> Timex.shift(days: -1) |> Timex.to_date())
    end_date = Keyword.get(opts, :end_date, Timex.now() |> Timex.shift(days: 2) |> Timex.to_date())
    service_exceptions = GTFSImport.get_service_exceptions(feed_id, start_date, end_date)

    for date <- %TimexInterval{from: start_date, until: end_date} do
      for service_id <- active_service_ids(date, feed_id, service_exceptions) do
        start_of_day = start_of_agency_day_utc(date, timezone)

        Logger.debug(fn ->
          "Adding projected stop times for agency: #{remote_id}, for service: #{service_id} on #{date}"
        end)

        {:ok, %{num_rows: num_rows}} =
          GTFSImport.add_projected_stop_times_for_service_date(service_id, agency_id, start_of_day)

        Logger.debug(fn -> "Added #{num_rows}" end)
      end
    end

    Logger.info("Done projecting stop times")
    GTFSImport.delete_old_projected_stop_times(Timex.shift(start_date, days: -1))
  end

  defp active_service_ids(date, feed_id, service_exceptions) do
    weekday_name = date |> Timex.format!("{WDfull}")

    feed_id
    |> GTFSImport.get_services(date)
    |> Enum.filter(fn service ->
      regular_service? = Service.weekday_schedule(service)[weekday_name]

      service_removals =
        service_exceptions
        |> Enum.filter(fn exception ->
          exception.date == date && exception.exception == @service_removal && exception.service_id == service.id
        end)

      service_additions =
        service_exceptions
        |> Enum.filter(fn exception ->
          exception.date == date && exception.exception == @service_addition && exception.service_id == service.id
        end)

      (Enum.empty?(service_removals) && regular_service?) || Enum.count(service_additions) > 0
    end)
    |> Enum.map(& &1.id)
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
