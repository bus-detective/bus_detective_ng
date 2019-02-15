defmodule Realtime.TripUpdates do
  @moduledoc """
  Main entrypoint for realtime trip updates
  """

  use GenServer

  require Logger

  alias Realtime.Messages.FeedMessage
  alias Realtime.StopTimeUpdateFinder

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
    trip_updates_url = Keyword.get(args, :trip_updates_url)
    name = via_tuple(feed_name)
    Logger.info(fn -> "Starting TripUpdates realtime process for #{feed_name} using url: #{trip_updates_url}" end)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def init(args) do
    schedule_fetch(500)

    {:ok,
     %{
       feed_name: args[:feed_name],
       trip_updates_url: args[:trip_updates_url],
       realtime_data: nil,
       last_fetched: nil
     }}
  end

  def find_stop_time(feed_name, trip_remote_id, stop_sequence) do
    case Registry.lookup(__MODULE__, feed_name) do
      [_ | _] ->
        GenServer.call(
          via_tuple(feed_name),
          {:find_stop_time, trip_remote_id, stop_sequence}
        )

      _ ->
        {:reply, {:error, :no_realtime_process}}
    end
  end

  def handle_call({:find_stop_time, _, _}, _, %{realtime_data: nil} = state), do: {:reply, {:error, :no_data}, state}

  def handle_call(
        {:find_stop_time, trip_remote_id, stop_sequence},
        _,
        %{realtime_data: realtime_data} = state
      ) do
    stop_time_update =
      StopTimeUpdateFinder.find_stop_time_update(
        realtime_data,
        trip_remote_id,
        stop_sequence
      )

    {:reply, {:ok, stop_time_update}, state}
  end

  def handle_info(:fetch_feed, state) do
    Logger.debug(fn -> "Updating TripUpdates realtime info for #{state.feed_name}" end)

    case HTTPoison.get(state.trip_updates_url) do
      {:ok, response} ->
        realtime = FeedMessage.decode(response.body)
        old_realtime = state.realtime_data
        state = %{state | realtime_data: realtime, last_fetched: Timex.now()}

        Logger.info(fn ->
          "Successfully refreshed TripUpdates realtime data for feed #{state.feed_name} at #{
            inspect(state.last_fetched)
          }"
        end)

        case is_nil(old_realtime) || old_realtime.header.timestamp != realtime.header.timestamp do
          true ->
            Logger.info("Pushing trip updates event notification")
            notify_subscribers()

          false ->
            Logger.debug("Realtime data timestamp matches old, skipping trip updates event notification")
        end

        schedule_fetch(17_000)
        {:noreply, state}

      error ->
        Logger.error(fn ->
          "Failed to fetch TripUpdates realtime data for feed #{inspect(state.feed_name)} at #{inspect(Timex.now())}, error: #{
            inspect(error)
          }"
        end)

        schedule_fetch(5_000)
        {:noreply, state}
    end
  end

  defp notify_subscribers do
    Registry.dispatch(Registry.Realtime, :trip_updates, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:realtime, :trip_updates})
      end
    end)
  end

  defp schedule_fetch(time_ms) do
    Process.send_after(self(), :fetch_feed, time_ms)
  end

  defp via_tuple(feed_name) do
    {:via, Registry, {__MODULE__, feed_name}}
  end
end
