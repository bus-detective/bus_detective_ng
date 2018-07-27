defmodule Importer.ScheduledImporter do
  @moduledoc """
  This GenServer is responsible for scheduled and calling the importer to
  updated the scheduled data once a day
  """

  use GenServer

  require Logger

  def child_spec(args) do
    %{
      id: args[:id],
      start: {__MODULE__, :start_link, [args]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def start_link(args) do
    feed_name = Keyword.get(args, :feed_name)
    gtfs_schedule_url = Keyword.get(args, :gtfs_schedule_url)
    name = via_tuple(feed_name)
    Logger.info(fn -> "Starting Scheduled Importer process for #{feed_name} using url: #{gtfs_schedule_url}" end)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def init(args) do
    feed_name = Keyword.get(args, :feed_name)
    gtfs_schedule_url = Keyword.get(args, :gtfs_schedule_url)
    schedule_work(5_000)
    {:ok, %{feed_name: feed_name, gtfs_schedule_url: gtfs_schedule_url}}
  end

  def handle_info(:work, state) do
    Importer.import_from_url(state.feed_name, state.gtfs_schedule_url)

    tomorrow =
      Timex.now()
      |> Timex.shift(days: 1)
      |> Timex.beginning_of_day()
      |> Timex.shift(hours: 8)
      |> Timex.diff(Timex.now(), :milliseconds)

    schedule_work(tomorrow)
    {:noreply, state}
  end

  defp schedule_work(delay) do
    Process.send_after(self(), :work, delay)
  end

  defp via_tuple(feed_name) do
    {:via, Registry, {__MODULE__, feed_name}}
  end
end
