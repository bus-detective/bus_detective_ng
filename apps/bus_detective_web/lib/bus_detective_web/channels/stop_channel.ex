defmodule BusDetectiveWeb.StopChannel do
  @moduledoc """
  Channel to manage stop events
  """
  use Phoenix.Channel

  alias BusDetective.GTFS
  alias Realtime.VehiclePositions

  intercept(["vehicle_positions"])

  def join("stops", %{"stop_id" => stop_id}, socket) do
    with {:ok, stop} <- GTFS.get_stop(stop_id),
         start_time <- Timex.shift(Timex.now(), minutes: -10),
         end_time <- Timex.shift(Timex.now(), hours: 1) do
      departures = GTFS.departures_for_stop(stop, start_time, end_time)
      Process.send_after(self(), :update_vehicle_positions, 500)
      {:ok, socket |> assign(:departures, departures) |> assign(:feed, stop.feed)}
    else
      _ ->
        {:error, :stop_not_found}
    end
  end

  def handle_info(:update_vehicle_positions, socket) do
    update_vehicle_positions(socket)
    {:noreply, socket}
  end

  def handle_out("vehicle_positions", %{}, socket) do
    update_vehicle_positions(socket)
    {:noreply, socket}
  end

  defp trip_ids(departures) do
    Enum.map(departures, fn departure -> departure.trip.remote_id end)
  end

  defp update_vehicle_positions(socket) do
    vehicle_positions =
      socket.assigns
      |> Map.get(:departures)
      |> trip_ids()
      |> Enum.map(fn trip_remote_id ->
        case VehiclePositions.find_vehicle_position(socket.assigns[:feed].name, trip_remote_id) do
          {:ok, position} -> position
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    push(socket, "vehicle_positions", %{vehicle_positions: vehicle_positions})
  end
end
