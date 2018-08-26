defmodule Realtime.VehiclePositions do
  @moduledoc """
  Main entrypoint for realtime vehicle positions
  """

  use GenServer

  require Logger

  alias Realtime.Messages.FeedMessage
  alias Realtime.{VehiclePositionFinder, VehiclePositionsSource}

  @behaviour VehiclePositionsSource

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
    vehicle_positions_url = Keyword.get(args, :vehicle_positions_url)
    name = via_tuple(feed_name)

    Logger.info(fn ->
      "Starting VehiclePositions realtime process for #{feed_name} using url: #{vehicle_positions_url}"
    end)

    GenServer.start_link(__MODULE__, args, name: name)
  end

  @impl GenServer
  def init(args) do
    schedule_fetch(500)

    {:ok,
     %{
       feed_name: args[:feed_name],
       vehicle_positions_url: args[:vehicle_positions_url],
       realtime_data: nil,
       last_fetched: nil
     }}
  end

  @impl VehiclePositionsSource
  def find_vehicle_position(feed_name, trip_remote_id) do
    case Registry.lookup(__MODULE__, feed_name) do
      [_ | _] ->
        GenServer.call(
          via_tuple(feed_name),
          {:find_vehicle_position, trip_remote_id}
        )

      _ ->
        {:reply, {:error, :no_realtime_process}}
    end
  end

  @impl GenServer
  def handle_call({:find_vehicle_position, _, _}, _, %{realtime_data: nil} = state),
    do: {:reply, {:error, :no_data}, state}

  def handle_call(
        {:find_vehicle_position, trip_remote_id},
        _,
        %{realtime_data: realtime_data} = state
      ) do
    case VehiclePositionFinder.find_vehicle_position(realtime_data, trip_remote_id) do
      nil ->
        {:reply, {:error, :no_position_data}, state}

      position ->
        {:reply, {:ok, position}, state}
    end
  end

  @impl GenServer
  def handle_info(:fetch_feed, state) do
    Logger.info(fn -> "Updating VehiclePositions realtime info for #{state.feed_name}" end)

    case HTTPoison.get(state.vehicle_positions_url) do
      {:ok, response} ->
        state = %{state | realtime_data: FeedMessage.decode(response.body), last_fetched: Timex.now()}

        Logger.info(fn ->
          "Successfully refreshed VehiclePositions realtime data for feed #{state.feed_name} at #{
            inspect(state.last_fetched)
          }"
        end)

        Registry.dispatch(Registry.Realtime, :vehicle_positions, fn entries ->
          for {pid, _} <- entries do
            send(pid, {:realtime, :vehicle_positions})
          end
        end)

        schedule_fetch(13_000)
        {:noreply, state}

      error ->
        Logger.error(fn ->
          "Failed to fetch VehiclePositions realtime data for feed #{inspect(state.feed_name)} at #{
            inspect(Timex.now())
          }, error: #{inspect(error)}"
        end)

        schedule_fetch(5_000)
        {:noreply, state}
    end
  end

  defp schedule_fetch(time_ms) do
    Process.send_after(self(), :fetch_feed, time_ms)
  end

  defp via_tuple(feed_name) do
    {:via, Registry, {__MODULE__, feed_name}}
  end
end
