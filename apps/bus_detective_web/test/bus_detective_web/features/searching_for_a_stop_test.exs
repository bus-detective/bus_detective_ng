defmodule SearchingForAStopTest do
  use BusDetectiveWeb.FeatureCase

  alias BusDetectiveWeb.{HomePage, SearchPage}

  setup do
    agency = insert(:agency)
    stop = insert(:stop, agency: agency)

    {:ok, stop: stop}
  end

  test "searching for a stop on the home page", %{session: session, stop: stop} do
    session
    |> HomePage.visit_page()
    |> HomePage.search(stop.name)
    |> assert_has(SearchPage.search_results(count: 1))
  end
end
