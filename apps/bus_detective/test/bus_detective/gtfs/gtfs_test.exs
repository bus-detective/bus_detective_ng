defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Service, Route, ServiceException, Stop}

  test "create_agency/1" do
    params = %{name: name} = params_for(:agency)

    assert {:ok, %Agency{name: ^name}} = GTFS.create_agency(params)
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
    service = GTFS.get_service(agency: agency, remote_id: remote_id)

    assert [service] == GTFS.list_services(agency: agency)
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

    assert [service_exception] == GTFS.list_service_exceptions(agency: agency, service: service)
  end

  test "create_route/1" do
    agency = insert(:agency)
    params = %{long_name: long_name} = params_for(:route, agency_id: agency.id)

    assert {:ok, %Route{long_name: ^long_name}} = GTFS.create_route(params)
  end

  test "list_routes/1" do
    agency = insert(:agency)
    %Route{remote_id: remote_id} = insert(:route, agency: agency)
    route = GTFS.get_route(agency: agency, remote_id: remote_id)

    assert [route] == GTFS.list_routes(agency: agency)
  end

  test "create_stop/1" do
    agency = insert(:agency)
    params = %{remote_id: remote_id} = params_for(:stop, agency_id: agency.id)

    assert {:ok, %Stop{remote_id: ^remote_id}} = GTFS.create_stop(params)
  end

  test "list_stops/1" do
    agency = insert(:agency)
    %Stop{remote_id: remote_id} = insert(:stop, agency: agency)
    stop = GTFS.get_stop(agency: agency, remote_id: remote_id)

    assert [stop] == GTFS.list_stops(agency: agency)
  end
end
