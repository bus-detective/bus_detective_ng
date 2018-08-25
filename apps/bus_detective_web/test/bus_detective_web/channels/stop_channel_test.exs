defmodule BusDetectiveWeb.StopChannelTest do
  use BusDetectiveWeb.ChannelCase, async: false

  import Mox

  alias BusDetectiveWeb.StopChannel
  alias Realtime.VehiclePosition

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    BusDetectiveWeb.VehiclePositionsMock
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

    {:ok, _, socket} = subscribe_and_join(socket(), StopChannel, "stops:#{stop.id}")

    {:ok, socket: socket, stop: stop, route_name: route_name, headsign: headsign}
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
end
