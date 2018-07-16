defmodule Realtime.TripUpdatesTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS.Trip
  alias Realtime.Messages.FeedMessage
  alias Realtime.TripUpdates

  setup do
    fixture = File.read!(Path.join(File.cwd!(), "test/fixtures/realtime_updates.buf"))
    feed = FeedMessage.decode(fixture)

    # |> Map.get(:entity) |> Enum.each(fn(feed_entity) -> Enum.each(feed_entity.trip_update.stop_time_update, fn(stop_time_update) -> IO.inspect(feed_entity) end) end) && nil
    {:ok, feed: feed}
  end

  describe "find_trip/1" do
    test "with a matching trip.remote_id it returns the correct TripUpdate", %{feed: feed} do
      trip = build(:trip, remote_id: "940135")
      assert trip.remote_id == TripUpdates.find_trip(feed, trip).trip.trip_id
    end

    test "with a non-matching trip.remote_id it returns nil", %{feed: feed} do
      trip = build(:trip, remote_id: "999999")
      assert is_nil(TripUpdates.find_trip(feed, trip))
    end
  end

  describe "find_stop_time/1" do
    test "with a matching stop_time.trip.remote_id, and stop_time.stop.remote.id, and stop_time.stop_sequence it returns a StopTimeUpdate for the stop_time",
         %{feed: feed} do
      trip = build(:trip, remote_id: "940135")
      stop = build(:stop, remote_id: "HAMBELi")
      stop_time = build(:stop_time, stop: stop, trip: trip, stop_sequence: 30)

      assert stop.remote_id == TripUpdates.find_stop_time(feed, stop_time).stop_id
    end

    test "with stop_sequence after one of the given it interprets the delay as the delay from the previous stop_sequence",
         %{feed: feed} do
      trip = build(:trip, remote_id: "940135")
      stop = build(:stop, remote_id: "NA")
      stop_time = build(:stop_time, stop: stop, trip: trip, stop_sequence: 99)

      assert %{stop_sequence: 97, delay: 120} = TripUpdates.find_stop_time(feed, stop_time)
    end

    test "with stop from a different trip with the same block number it interprets the delay as the delay from the last stop_sequence of the previous trip on the block",
         %{feed: feed} do
      block_id = "12345"
      %Trip{agency: agency} = insert(:trip, remote_id: "940135", block_id: block_id)
      trip = insert(:trip, agency: agency, remote_id: "940136", block_id: block_id)
      stop = build(:stop, remote_id: "NA")
      stop_time = build(:stop_time, stop: stop, trip: trip, stop_sequence: 1)

      assert %{stop_sequence: 97, delay: 120} = TripUpdates.find_stop_time(feed, stop_time)
    end

    test "with a non-matching stop_time it returns nil", %{feed: feed} do
      stop_time = build(:stop_time)
      assert is_nil(TripUpdates.find_stop_time(feed, stop_time))
    end
  end
end
