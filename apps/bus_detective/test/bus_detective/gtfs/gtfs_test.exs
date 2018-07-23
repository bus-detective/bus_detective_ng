defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Feed, Service, Route, ServiceException, Shape, Stop, StopTime, Trip}

  test "create_agency/1" do
    %Feed{id: feed_id} = insert(:feed)
    params = %{name: name} = params_for(:agency, feed_id: feed_id)

    assert {:ok, %Agency{name: ^name}} = GTFS.create_agency(params)
  end

  test "list_agencies/0" do
    agency = insert(:agency)

    assert agency.id == Enum.at(GTFS.list_agencies(), 0).id
  end

  test "create_service/1" do
    feed = insert(:feed)
    params = %{remote_id: remote_id} = params_for(:service, feed_id: feed.id)

    assert {:ok, %Service{remote_id: ^remote_id}} = GTFS.create_service(params)
  end

  test "list_services/1" do
    feed = insert(:feed)
    %Service{remote_id: remote_id} = insert(:service, feed: feed)
    service = GTFS.get_service(feed, remote_id)

    assert [service] == GTFS.list_services(feed)
  end

  test "create_service_exception/1" do
    feed = insert(:feed)
    service = insert(:service, feed: feed)
    params = %{date: date} = params_for(:service_exception, feed_id: feed.id, service_id: service.id)

    assert {:ok, %ServiceException{date: ^date}} = GTFS.create_service_exception(params)
  end

  test "list_service_exceptions/1" do
    feed = insert(:feed)
    service = insert(:service, feed: feed)
    service_exception = GTFS.get_service_exception!(insert(:service_exception, feed: feed, service: service).id)

    assert [service_exception] == GTFS.list_service_exceptions(feed, service)
  end

  test "create_route/1" do
    feed = insert(:feed)
    agency = insert(:agency, feed: feed)
    params = %{long_name: long_name} = params_for(:route, feed_id: feed.id, agency_id: agency.id)

    assert {:ok, %Route{long_name: ^long_name}} = GTFS.create_route(params)
  end

  test "list_routes/1" do
    feed = insert(:feed)
    %Route{remote_id: remote_id} = insert(:route, feed: feed)
    route = GTFS.get_route(feed, remote_id)

    assert [route] == GTFS.list_routes(feed)
  end

  test "create_stop/1" do
    feed = insert(:feed)
    params = %{remote_id: remote_id} = params_for(:stop, feed_id: feed.id)

    assert {:ok, %Stop{remote_id: ^remote_id}} = GTFS.create_stop(params)
  end

  test "list_stops/1" do
    feed = insert(:feed)
    %Stop{remote_id: remote_id} = insert(:stop, feed: feed)
    stop = GTFS.get_stop(feed, remote_id)

    assert [stop] == GTFS.list_stops(feed)
  end

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

  test "create_shape/1" do
    feed = insert(:feed)
    params = %{remote_id: remote_id} = params_for(:shape, feed_id: feed.id)

    assert {:ok, %Shape{remote_id: ^remote_id}} = GTFS.create_shape(params)
  end

  test "list_shapes/1" do
    feed = insert(:feed)
    %Shape{remote_id: remote_id} = insert(:shape, feed: feed)
    shape = GTFS.get_shape(feed, remote_id)

    assert [shape] == GTFS.list_shapes(feed)
  end

  test "create_trip/1" do
    feed = insert(:feed)
    service = insert(:service, feed: feed)
    route = insert(:route, feed: feed)
    shape = insert(:shape, feed: feed)

    params =
      %{remote_id: remote_id} =
      params_for(:trip, feed_id: feed.id, shape_id: shape.id, service_id: service.id, route_id: route.id)

    assert {:ok, %Trip{remote_id: ^remote_id}} = GTFS.create_trip(params)
  end

  test "list_trips/1" do
    feed = insert(:feed)
    service = insert(:service, feed: feed)
    route = insert(:route, feed: feed)

    %Trip{remote_id: remote_id} = insert(:trip, feed: feed, service: service, route: route)
    trip = GTFS.get_trip(feed, remote_id)

    assert [trip] == GTFS.list_trips(feed)
  end

  test "create_stop_time/1" do
    feed = insert(:feed)
    stop = :stop |> build() |> with_feed(feed) |> insert()
    trip = :trip |> build() |> with_feed(feed) |> insert()

    params = %{stop_sequence: stop_sequence} = params_for(:stop_time, feed: feed, stop: stop, trip: trip)

    assert {:ok, %StopTime{stop_sequence: ^stop_sequence}} = GTFS.create_stop_time(params)
  end

  test "list_stop_times/1" do
    feed = insert(:feed)
    stop = :stop |> build() |> with_feed(feed) |> insert()
    trip = :trip |> build() |> with_feed(feed) |> insert()

    %StopTime{stop_sequence: stop_sequence} = insert(:stop_time, feed: feed, stop: stop, trip: trip)

    stop_time = GTFS.get_stop_time(feed, stop, stop_sequence, trip)

    assert 1 == length(GTFS.list_stop_times(feed))
    assert stop_time.id == List.first(GTFS.list_stop_times(feed)).id
  end
end
