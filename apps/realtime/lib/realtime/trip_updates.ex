defmodule Realtime.TripUpdates do
  @moduledoc """
  Main entrypoint for realtime trip updates
  """

  use GenServer

  require Logger

  alias Realtime.Messages.FeedMessage
  alias Realtime.StopTimeUpdateFinder

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    schedule_fetch(500)
    {:ok, args}
  end

  def find_stop_time(block_id, trip_remote_id, stop_sequence, fetch_related_trips_fn) do
    GenServer.call(__MODULE__, {:find_stop_time, block_id, trip_remote_id, stop_sequence, fetch_related_trips_fn})
  end

  def handle_call({:find_stop_time, block_id, trip_remote_id, stop_sequence, fetch_related_trips_fn}, _, feed) do
    stop_time_update =
      StopTimeUpdateFinder.find_stop_time(feed, block_id, trip_remote_id, stop_sequence, fetch_related_trips_fn)

    {:reply, {:ok, stop_time_update}, feed}
  end

  def handle_info(:fetch_feed, state) do
    case HTTPoison.get("http://developer.go-metro.com/TMGTFSRealTimeWebService/TripUpdate/TripUpdates.pb") do
      {:ok, response} ->
        state = FeedMessage.decode(response.body)
        schedule_fetch(60_000)
        {:noreply, state}

      error ->
        Logger.error(fn -> error end)
        schedule_fetch(5_000)
        {:noreply, state}
    end
  end

  defp schedule_fetch(time_ms) do
    Process.send_after(self(), :fetch_feed, time_ms)
  end
end
