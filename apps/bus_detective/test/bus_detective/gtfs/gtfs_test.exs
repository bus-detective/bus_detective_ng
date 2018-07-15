defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Service, Route, RouteStop, ServiceException, Shape, Stop, StopTime, Trip}
  alias BusDetective.Repo

  test "create_agency/1" do
    params = %{name: name} = params_for(:agency)

    assert {:ok, %Agency{name: ^name}} = GTFS.create_agency(params)
  end

  test "destroy_agency/1" do
    agency = insert(:agency)
    service = insert(:service, agency: agency)
    stop = insert(:stop, agency: agency)
    route = insert(:route, agency: agency)
    insert(:route_stop, route: route, stop: stop)
    shape = insert(:shape, agency: agency)
    trip = insert(:trip, agency: agency, route: route, service: service, shape: shape)
    insert(:stop_time, agency: agency, stop: stop, trip: trip)

    GTFS.destroy_agency(agency.remote_id)

    assert 0 == Repo.aggregate(Agency, :count, :id)
    assert 0 == Repo.aggregate(Service, :count, :id)
    assert 0 == Repo.aggregate(Stop, :count, :id)
    assert 0 == Repo.aggregate(Route, :count, :id)
    assert 0 == Repo.aggregate(RouteStop, :count, :id)
    assert 0 == Repo.aggregate(Shape, :count, :id)
    assert 0 == Repo.aggregate(Trip, :count, :id)
    assert 0 == Repo.aggregate(StopTime, :count, :id)
  end

  test "list_agencies/0" do
    agency = insert(:agency)

    assert [agency] == GTFS.list_agencies()
  end

  test "create_service/1" do
    agency = insert(:agency)
    params = %{remote_id: remote_id} = params_for(:service, agency_id: agency.id)

    assert {:ok, %Service{remote_id: ^remote_id}} = GTFS.create_service(params)
  end

  test "list_services/1" do
    agency = insert(:agency)
    %Service{remote_id: remote_id} = insert(:service, agency: agency)
    service = GTFS.get_service(agency, remote_id)

    assert [service] == GTFS.list_services(agency)
  end

  test "create_service_exception/1" do
    agency = insert(:agency)
    service = insert(:service, agency: agency)
    params = %{date: date} = params_for(:service_exception, agency_id: agency.id, service_id: service.id)

    assert {:ok, %ServiceException{date: ^date}} = GTFS.create_service_exception(params)
  end

  test "list_service_exceptions/1" do
    agency = insert(:agency)
    service = insert(:service, agency: agency)
    service_exception = GTFS.get_service_exception!(insert(:service_exception, agency: agency, service: service).id)

    assert [service_exception] == GTFS.list_service_exceptions(agency, service)
  end

  test "create_route/1" do
    agency = insert(:agency)
    params = %{long_name: long_name} = params_for(:route, agency_id: agency.id)

    assert {:ok, %Route{long_name: ^long_name}} = GTFS.create_route(params)
  end

  test "list_routes/1" do
    agency = insert(:agency)
    %Route{remote_id: remote_id} = insert(:route, agency: agency)
    route = GTFS.get_route(agency, remote_id)

    assert [route] == GTFS.list_routes(agency)
  end

  test "create_stop/1" do
    agency = insert(:agency)
    params = %{remote_id: remote_id} = params_for(:stop, agency_id: agency.id)

    assert {:ok, %Stop{remote_id: ^remote_id}} = GTFS.create_stop(params)
  end

  test "list_stops/1" do
    agency = insert(:agency)
    %Stop{remote_id: remote_id} = insert(:stop, agency: agency)
    stop = GTFS.get_stop(agency, remote_id)

    assert [stop] == GTFS.list_stops(agency)
  end

  test "create_shape/1" do
    agency = insert(:agency)
    params = %{remote_id: remote_id} = params_for(:shape, agency_id: agency.id)

    assert {:ok, %Shape{remote_id: ^remote_id}} = GTFS.create_shape(params)
  end

  test "list_shapes/1" do
    agency = insert(:agency)
    %Shape{remote_id: remote_id} = insert(:shape, agency: agency)
    shape = GTFS.get_shape(agency, remote_id)

    assert [shape] == GTFS.list_shapes(agency)
  end

  test "create_trip/1" do
    agency = insert(:agency)
    service = insert(:service, agency: agency)
    route = insert(:route, agency: agency)
    shape = insert(:shape, agency: agency)

    params =
      %{remote_id: remote_id} =
      params_for(:trip, agency_id: agency.id, shape_id: shape.id, service_id: service.id, route_id: route.id)

    assert {:ok, %Trip{remote_id: ^remote_id}} = GTFS.create_trip(params)
  end

  test "list_trips/1" do
    agency = insert(:agency)
    service = insert(:service, agency: agency)
    route = insert(:route, agency: agency)

    %Trip{remote_id: remote_id} = insert(:trip, agency: agency, service: service, route: route)
    trip = GTFS.get_trip(agency, remote_id)

    assert [trip] == GTFS.list_trips(agency)
  end

  test "create_stop_time/1" do
    agency = insert(:agency)
    stop = insert(:stop, agency: agency)
    trip = insert(:trip, agency: agency)

    params =
      %{stop_sequence: stop_sequence} = params_for(:stop_time, agency_id: agency.id, stop_id: stop.id, trip_id: trip.id)

    assert {:ok, %StopTime{stop_sequence: ^stop_sequence}} = GTFS.create_stop_time(params)
  end

  test "list_stop_times/1" do
    agency = insert(:agency)
    stop = insert(:stop, agency: agency)
    trip = insert(:trip, agency: agency)

    %StopTime{stop_sequence: stop_sequence} = insert(:stop_time, agency: agency, stop: stop, trip: trip)

    stop_time = GTFS.get_stop_time(agency, stop, stop_sequence, trip)

    assert 1 == length(GTFS.list_stop_times(agency))
    assert stop_time.id == List.first(GTFS.list_stop_times(agency)).id
  end
end
