defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Stop
  alias Geo.Point

  describe "search_stops/1" do
    setup do
      feed = insert(:feed)

      {:ok, feed: feed}
    end

    test "by query with a single word it returns only the matching stop", %{feed: feed} do
      stop = insert(:stop, feed: feed, name: "8th & Walnut", code: "1234")
      insert(:stop, feed: feed, name: "7th & Main", code: "456")

      results = GTFS.search_stops(query: "walnut")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "by query with multiple words it returns only the matching stop", %{feed: feed} do
      stop = insert(:stop, feed: feed, name: "8th & Walnut", code: "1234")
      insert(:stop, feed: feed, name: "7th & Main", code: "456")

      results = GTFS.search_stops(query: "walnut 8th")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "by query with a 'and' instead of '&' it returns only the matching stop", %{feed: feed} do
      stop = insert(:stop, feed: feed, name: "8th & Walnut", code: "1234")
      insert(:stop, feed: feed, name: "7th & Main", code: "456")

      results = GTFS.search_stops(query: "8th and walnut")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "by query with a spelled out street it returns only the matching stop", %{feed: feed} do
      stop = insert(:stop, feed: feed, name: "8th & Walnut", code: "1234")
      insert(:stop, feed: feed, name: "7th & Main", code: "456")

      results = GTFS.search_stops(query: "eight")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "by query with a number for the street it returns only the matching stop", %{feed: feed} do
      stop = insert(:stop, feed: feed, name: "8th & Walnut", code: "1234")
      insert(:stop, feed: feed, name: "7th & Main", code: "456")

      results = GTFS.search_stops(query: "8")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "by query with a stop code it returns only the matching stop", %{feed: feed} do
      stop = insert(:stop, feed: feed, name: "8th & Walnut", code: "1234")
      insert(:stop, feed: feed, name: "7th & Main", code: "456")

      results = GTFS.search_stops(query: "1234")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "searching with a latitude and longitude returns correct results", %{feed: feed} do
      %Stop{id: far_stop_id} =
        insert(:stop, feed: feed, location: %Point{coordinates: {-85.511653, 38.104836}, srid: 4326})

      %Stop{id: near_stop_id} =
        insert(:stop, feed: feed, location: %Point{coordinates: {-84.511653, 39.104836}, srid: 4326})

      results = GTFS.search_stops(longitude: -84.5118910, latitude: 39.1043200)

      assert [near_stop_id, far_stop_id] == Enum.map(results, & &1.id)
    end

    test "it pages correctly", %{feed: feed} do
      for x <- 1..20 do
        insert(:stop, feed: feed, name: "thing #{x}")
      end

      results = GTFS.search_stops(query: "thing", page: 1, page_size: 7)

      assert 3 == results.total_pages
      assert 20 == results.total_entries
      assert 1 == results.page_number
      assert 7 == results.page_size
    end

    test "searching with a number above 100 doesn't error" do
      assert Enum.empty?(GTFS.search_stops(query: "105"))
    end
  end

  describe "get_stop/1" do
    setup do
      stop = insert(:stop)
      insert(:stop)

      {:ok, stop: stop}
    end

    test "when given a nil it returns a nil result" do
      assert is_nil(GTFS.get_stop(nil))
    end

    test "when given an existing id it returns the stop", %{stop: %Stop{id: stop_id}} do
      assert {:ok, %Stop{id: ^stop_id}} = GTFS.get_stop(stop_id)
    end
  end

  describe "get_stop/2" do
    setup do
      stop = insert(:stop)
      insert(:stop)

      {:ok, stop: stop}
    end

    test "when given a nil it returns a nil result" do
      assert is_nil(GTFS.get_stop(nil))
    end

    test "when given an existing id it returns the stop", %{stop: %Stop{id: stop_id} = stop} do
      assert {:ok, %Stop{id: ^stop_id}} = GTFS.get_stop(stop.feed_id, stop.remote_id)
    end
  end

  describe "get_stops/1" do
    setup do
      feed = insert(:feed)
      stop = insert(:stop, feed: feed)
      insert(:stop, feed: feed)

      {:ok, stop: stop}
    end

    test "when given an empty list it returns and empty list of results" do
      assert [] == GTFS.get_stops([])
    end

    test "when given valid ids it returns the stops", %{stop: stop} do
      actual = GTFS.get_stops(["#{stop.feed_id}-#{stop.remote_id}"])
      assert 1 = Enum.count(actual)
      assert stop.id == List.first([stop.id])
    end
  end

  describe "subscribe_to_realtime/1" do
    test "subscribing to registry events returns :ok" do
      assert :ok == GTFS.subscribe_to_realtime(:trip_updates)
    end
  end
end
