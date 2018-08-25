defmodule BusDetectiveWeb.StopChannelTest do
  use BusDetectiveWeb.ChannelCase

  alias BusDetectiveWeb.StopChannel

  setup do
    stop = insert(:stop)
    {:ok, _, socket} = subscribe_and_join(socket(), StopChannel, "stops:#{stop.id}")

    {:ok, socket: socket, stop: stop}
  end

  test "it updates vehicle positions right after join" do
    assert_push("vehicle_positions", %{}, 1000)
  end

  test "it updates vehicle positions after vehicle position update broadcast", %{socket: socket} do
    assert_push("vehicle_positions", %{}, 1000)
    broadcast_from!(socket, "vehicle_positions", %{})
    assert_push("vehicle_positions", %{})
  end
end
