defmodule BusDetectiveWeb.StopChannel do
  @moduledoc """
  Channel to manage stop events
  """
  use Phoenix.Channel

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Shape
  alias BusDetectiveWeb.DepartureView
  alias Phoenix.View
  alias Realtime.VehiclePositions

  intercept(["vehicle_positions", "trip_updates"])

  def join("stops", %{"stop_id" => stop_id}, socket) do
    Process.send_after(self(), :update_departures, 100)
    {:ok, assign(socket, :stop_id, stop_id)}
  end

  def handle_in("reload_departures", _, socket) do
    {:noreply, update_departures(socket)}
  end

  def handle_info(:update_departures, socket) do
    {:noreply, update_departures(socket)}
  end

  def handle_info(:update_vehicle_positions, socket) do
    {:noreply, update_vehicle_positions(socket)}
  end

  def handle_out("trip_updates", %{}, socket) do
    {:noreply, update_departures(socket)}
  end

  def handle_out("vehicle_positions", %{}, socket) do
    {:noreply, update_vehicle_positions(socket)}
  end

  defp update_departures(socket) do
    with {:ok, stop} <- GTFS.get_stop(socket.assigns[:stop_id]),
         start_time <- Timex.shift(Timex.now(), minutes: -10),
         end_time <- Timex.shift(Timex.now(), hours: 1) do
      departures = GTFS.departures_for_stop(stop, start_time, end_time)

      rendered_departures =
        Enum.map(departures, fn departure ->
          %{
            id: departure.trip.remote_id,
            time: departure.time,
            headsign: departure.trip.headsign,
            route_name: departure.route.short_name,
            route_color: departure.route.color,
            route_text_color: departure.route.text_color,
            realtime: departure.realtime?
          }
        end)

      push(socket, "departures", %{departures: rendered_departures})

      socket =
        socket
        |> assign(:departures, departures)
        |> assign(:feed, stop.feed)
        |> update_trip_shapes()

      Process.send_after(self(), :update_vehicle_positions, 10)

      socket
    else
      _ ->
        {:error, :stop_not_found}
    end
  end

  defp update_trip_shapes(socket) do
    trip_shapes =
      socket.assigns
      |> Map.get(:departures)
      |> Enum.map(fn departure ->
        %{
          coordinates: Shape.coordinates_to_map(departure.trip.shape),
          headsign: departure.trip.headsign,
          route_name: departure.route.short_name,
          route_color: departure.route.color,
          route_text_color: departure.route.text_color,
          shape_id: departure.trip.shape_id
        }
      end)

    push(socket, "trip_shapes", %{shapes: trip_shapes})
    socket
  end

  defp update_vehicle_positions(socket) do
    vehicle_positions =
      socket.assigns
      |> Map.get(:departures)
      |> Enum.map(fn departure ->
        trip_remote_id = departure.trip.remote_id

        case vehicle_positions_source().find_vehicle_position(socket.assigns[:feed].name, trip_remote_id) do
          {:ok, position} ->
            vehicle_label = position.vehicle_label || position.id

            position
            |> Map.take([:latitude, :longitude, :trip_id])
            |> Map.merge(%{
              headsign: departure.trip.headsign,
              route_name: departure.route.short_name,
              route_color: departure.route.color,
              route_text_color: departure.route.text_color,
              vehicle_label: vehicle_label
            })

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    push(socket, "vehicle_positions", %{vehicle_positions: vehicle_positions})
    socket
  end

  defp vehicle_positions_source do
    Application.get_env(:realtime, :vehicle_positions_source) || VehiclePositions
  end
end
