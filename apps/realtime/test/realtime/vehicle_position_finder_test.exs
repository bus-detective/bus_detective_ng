defmodule Realtime.VehiclePositionFinderTest do
  use ExUnit.Case

  alias Realtime.Messages.FeedMessage
  alias Realtime.VehiclePositionFinder

  setup do
    fixture = File.read!(Path.join(File.cwd!(), "test/fixtures/VehiclePositions.pb"))
    feed = FeedMessage.decode(fixture)
    {:ok, feed: feed}
  end

  describe "find_vehicle_position/2" do
    test "with a trip remote id that matches a realtime update", %{feed: feed} do
      assert %{trip_id: "1090758", latitude: 39.1627197265625, longitude: -84.42084503173828, vehicle_label: "1323"} =
               VehiclePositionFinder.find_vehicle_position(feed, "1090758")
    end

    test "with a trip remote id that does not match a realtime update", %{feed: feed} do
      assert is_nil(VehiclePositionFinder.find_vehicle_position(feed, "11111"))
    end
  end
end
