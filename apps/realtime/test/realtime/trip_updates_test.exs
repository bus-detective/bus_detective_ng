defmodule Realtime.TripUpdatesTest do
  use ExUnit.Case

  alias Realtime.Messages.FeedMessage
  alias Realtime.TripUpdates

  setup do
    fixture = File.read!(Path.join(File.cwd!(), "test/fixtures/realtime_updates.buf"))
    feed = FeedMessage.decode(fixture)
    {:ok, feed: feed}
  end

  describe "find_trip/1" do
    test "with a matching trip.remote_trip_id it returns the correct TripUpdate", %{feed: feed} do
      remote_trip_id = "940135"
      assert remote_trip_id == TripUpdates.find_trip(feed, remote_trip_id).trip.trip_id
    end

    test "with a non-matching trip.remote_trip_id it returns nil", %{feed: feed} do
      remote_trip_id = "999999"
      assert is_nil(TripUpdates.find_trip(feed, remote_trip_id))
    end
  end

  describe "find_stop_time/1" do
    setup do
      fetch_related_trips = fn "12345" ->
        ["940135", "940136"]
      end

      {:ok, fetch_related_trips: fetch_related_trips}
    end

    test "with a matching stop_time.trip.remote_trip_id, and stop_time.stop.remote.id, and stop_time.stop_sequence it returns a StopTimeUpdate for the stop_time",
         %{feed: feed, fetch_related_trips: fetch_related_trips} do
      assert %{stop_id: "HAMBELi"} = TripUpdates.find_stop_time(feed, nil, "940135", 30, fetch_related_trips)
    end

    test "with stop_sequence after one of the given it interprets the delay as the delay from the previous stop_sequence",
         %{feed: feed, fetch_related_trips: fetch_related_trips} do
      assert %{stop_sequence: 97, delay: 120} = TripUpdates.find_stop_time(feed, nil, "940135", 99, fetch_related_trips)
    end

    test "with stop from a different trip with the same block number it interprets the delay as the delay from the last stop_sequence of the previous trip on the block",
         %{feed: feed, fetch_related_trips: fetch_related_trips} do
      assert %{stop_sequence: 97, delay: 120} =
               TripUpdates.find_stop_time(feed, "12345", "940136", 1, fetch_related_trips)
    end

    test "with a non-matching stop_time it returns nil", %{feed: feed} do
      fetch_related_trips = fn _ -> [] end

      assert is_nil(TripUpdates.find_stop_time(feed, "99999", "11111", 42, fetch_related_trips))
    end
  end
end
