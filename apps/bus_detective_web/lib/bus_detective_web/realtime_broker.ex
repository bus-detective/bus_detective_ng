defmodule BusDetectiveWeb.RealtimeBroker do
  @moduledoc """
  This module receives realtime updates as they occur and broadcasts the events to the appropriate channels
  """

  use GenServer

  alias BusDetective.GTFS
  alias BusDetectiveWeb.Endpoint

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    GTFS.subscribe_to_realtime(:trip_updates)
    GTFS.subscribe_to_realtime(:vehicle_positions)
    {:ok, []}
  end

  def handle_info({:realtime, :trip_updates}, state) do
    Endpoint.broadcast("stops", "trip_updates", %{})
    {:noreply, state}
  end

  def handle_info({:realtime, :vehicle_positions}, state) do
    Endpoint.broadcast("stops", "vehicle_positions", %{})
    {:noreply, state}
  end
end
