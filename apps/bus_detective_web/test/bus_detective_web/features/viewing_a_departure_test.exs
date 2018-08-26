defmodule ViewingADepartureTest do
  use BusDetectiveWeb.FeatureCase

  import Mox

  alias BusDetectiveWeb.StopPage
  alias Realtime.VehiclePosition

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    Realtime.TripUpdatesMock
    |> stub(:find_stop_time, fn _feed_name, _stop_remote_id, _stop_sequence ->
      {:error, :no_realtime_process}
    end)

    Realtime.VehiclePositionsMock
    |> stub(:find_vehicle_position, fn _feed_name, trip_remote_id ->
      {:ok, %VehiclePosition{trip_id: trip_remote_id, latitude: 1.9, longitude: 1.9}}
    end)

    feed = insert(:feed)
    agency = :agency |> build(feed: feed) |> insert()
    service = :service |> build() |> with_feed(feed) |> insert()
    stop = :stop |> build() |> with_feed(feed) |> insert()
    route = :route |> build() |> with_feed(feed) |> with_agency(agency) |> insert()
    insert(:route_stop, route: route, stop: stop)
    shape = :shape |> build() |> with_feed(feed) |> insert()
    trip = insert(:trip, feed: feed, route: route, service: service, shape: shape)
    stop_time = insert(:stop_time, feed: feed, stop: stop, trip: trip)

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
