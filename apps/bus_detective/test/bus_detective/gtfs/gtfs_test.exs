defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Service}

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
end
