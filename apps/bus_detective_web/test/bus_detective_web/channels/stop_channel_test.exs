defmodule BusDetectiveWeb.StopChannelTest do
  use BusDetectiveWeb.ChannelCase, async: false

  import Mox

  alias BusDetectiveWeb.StopChannel
  alias Realtime.VehiclePosition

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    Realtime.TripUpdatesMock
    |> stub(:find_stop_time, fn _feed_name, _stop_remote_id, _stop_sequence ->
      {:error, :no_realtime_process}
    end)

    Realtime.VehiclePositionsMock
    |> stub(:find_vehicle_position, fn _feed_name, trip_remote_id ->
      {:ok, %VehiclePosition{trip_id: trip_remote_id}}
    end)

    headsign = "This is a headsign"
    route_name = "67X"
    feed = insert(:feed)
    route = :route |> build(short_name: route_name) |> with_feed(feed) |> insert()
    trip = :trip |> build(route: route, headsign: headsign) |> with_feed(feed) |> insert()
    stop = :stop |> build() |> with_feed(feed) |> insert()
    stop_time = :stop_time |> build(trip: trip, stop: stop) |> with_feed(feed) |> insert()
    insert(:projected_stop_time, stop_time: stop_time)

    {:ok, _, socket} = subscribe_and_join(socket(), StopChannel, "stops", %{"stop_id" => stop.id})

    {:ok, socket: socket, stop: stop, route_name: route_name, headsign: headsign}
  end

  test "it updates departures right after join" do
    assert_push("departures", %{departures: _}, 1000)
  end

  test "it updates departures when client requests", %{socket: socket} do
    assert_push("departures", %{departures: _}, 1000)
    push(socket, "reload_departures", %{})
    assert_push("departures", %{departures: _})
  end

  test "it updates departures after trip updates broadcast", %{socket: socket} do
    assert_push("departures", %{departures: _}, 1000)
    broadcast_from!(socket, "trip_updates", %{})
    assert_push("departures", %{departures: _})
  end

  test "it updates vehicle positions right after join" do
    assert_push("vehicle_positions", %{vehicle_positions: _}, 1000)
  end

  test "it updates vehicle positions after vehicle position update broadcast", %{socket: socket} do
    assert_push("vehicle_positions", %{}, 1000)
    broadcast_from!(socket, "vehicle_positions", %{})
    assert_push("vehicle_positions", %{vehicle_positions: _})
  end

  test "vehicle positions include relevant trip information", %{route_name: route_name, headsign: headsign} do
    assert_push("vehicle_positions", %{vehicle_positions: [%{headsign: ^headsign, route_name: ^route_name}]}, 1000)
  end

  test "it updates trip_shapes after trip updates broadcast", %{socket: socket} do
    assert_push("trip_shapes", %{shapes: _}, 1000)
    broadcast_from!(socket, "trip_updates", %{})
    assert_push("trip_shapes", %{shapes: _})
  end

  test "it updates trip_shapes right after join" do
    assert_push("trip_shapes", %{shapes: _}, 1000)
  end

  test "trip_shapes include relevant trip and shape information", %{route_name: route_name, headsign: headsign} do
    assert_push(
      "trip_shapes",
      %{shapes: [%{headsign: ^headsign, route_name: ^route_name, coordinates: [_ | _], shape_id: _}]},
      1000
    )
  end
end
