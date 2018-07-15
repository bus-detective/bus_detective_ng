defmodule ViewingADepartureTest do
  use BusDetectiveWeb.FeatureCase

  alias BusDetectiveWeb.StopPage

  setup do
    agency = insert(:agency)
    service = insert(:service, agency: agency)
    stop = insert(:stop, agency: agency)
    route = insert(:route, agency: agency)
    insert(:route_stop, route: route, stop: stop)
    shape = insert(:shape, agency: agency)
    trip = insert(:trip, agency: agency, route: route, service: service, shape: shape)
    stop_time = insert(:stop_time, agency: agency, stop: stop, trip: trip)

    departure_time = Timex.shift(Timex.now(), minutes: 5)

    insert(
      :projected_stop_time,
      stop_time: stop_time,
      scheduled_arrival_time: departure_time,
      scheduled_departure_time: departure_time
    )

    {:ok, stop: stop, stop_time: stop_time}
  end

  test "viewing a departure on the stop page", %{session: session, stop: stop} do
    session
    |> StopPage.visit_page(stop)
    |> assert_has(StopPage.departure_results(count: 1))
  end
end
