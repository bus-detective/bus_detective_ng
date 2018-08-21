defmodule FavoritingAStopTest do
  use BusDetectiveWeb.FeatureCase

  alias BusDetectiveWeb.{HomePage, SearchPage}

  setup do
    stop = insert(:stop)

    {:ok, stop: stop}
  end

  test "favoriting a stop", %{session: session, stop: stop} do
    session
    |> HomePage.visit_page()
    |> HomePage.search(stop.name)
    |> assert_has(SearchPage.search_results(count: 1))
    |> SearchPage.favorite_stop(stop)
    |> HomePage.visit_page()
    |> assert_has(HomePage.favorite(stop))
  end
end
