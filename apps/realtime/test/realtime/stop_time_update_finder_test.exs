defmodule Realtime.StopTimeUpdateFinderTest do
  use ExUnit.Case

  alias Realtime.Messages.FeedMessage
  alias Realtime.StopTimeUpdateFinder

  setup do
    fixture = File.read!(Path.join(File.cwd!(), "test/fixtures/realtime_updates.buf"))
    feed = FeedMessage.decode(fixture)
    {:ok, feed: feed}
  end

  describe "find_exact_trip/1" do
    test "with a matching trip.remote_trip_id it returns the correct TripUpdate", %{feed: feed} do
      remote_trip_id = "940135"
      assert remote_trip_id == StopTimeUpdateFinder.find_exact_trip(feed, remote_trip_id).trip.trip_id
    end

    test "with a non-matching trip.remote_trip_id it returns nil", %{feed: feed} do
      remote_trip_id = "999999"
      assert is_nil(StopTimeUpdateFinder.find_exact_trip(feed, remote_trip_id))
    end
  end

  describe "find_stop_time_update/1" do
    test "with a matching stop_time.trip.remote_trip_id, and stop_time.stop.remote.id, and stop_time.stop_sequence it returns a StopTimeUpdate for the stop_time",
         %{feed: feed} do
      assert %{stop_id: "HAMBELi"} = StopTimeUpdateFinder.find_stop_time_update(feed, "940135", 30)
    end

    test "with a non-matching stop_time it returns nil", %{feed: feed} do
      assert is_nil(StopTimeUpdateFinder.find_stop_time_update(feed, "11111", 42))
    end
  end
end
