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

    test "search is case-insensitive", %{feed: feed} do
      insert(:stop, feed: feed, name: "unrelated")
      stop = insert(:stop, feed: feed, name: "BIG TIME STOP")

      results = GTFS.search_stops(query: "big time")

      assert 1 == Enum.count(results)
      assert stop.id == Enum.at(results, 0).id
    end

    test "searching by partial name returns the correct results", %{feed: feed} do
      insert(:stop, feed: feed, name: "unrelated")
      stop = insert(:stop, feed: feed, name: "This is a stop & it's great")

      results = GTFS.search_stops(query: "great")

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
  end
end
