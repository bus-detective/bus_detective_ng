defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS

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
