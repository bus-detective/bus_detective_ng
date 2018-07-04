defmodule Importer.ImporterTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Service, ServiceException}

  setup do
    gtfs_file = Path.join(File.cwd!(), "test/fixtures/google_transit_info.zip")
    {:ok, gtfs_file: gtfs_file}
  end

  test "it imports the correct number of agencies", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)

    assert 1 == length(GTFS.list_agencies())
  end

  test "it imports the agency correctly", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)

    agency = GTFS.list_agencies() |> List.first()

    assert %Agency{
             fare_url: "http://www.go-metro.com/fares-passes",
             remote_id: "SORTA",
             language: "en",
             name: "Southwest Ohio Regional Transit Authority",
             phone: "513-621-4455",
             timezone: "America/Detroit",
             url: "http://www.go-metro.com"
           } = agency
  end

  test "it imports the correct number of services", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 3 == length(GTFS.list_services(agency: agency))
  end

  test "it imports a service correctly", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)

    [agency] = GTFS.list_agencies()
    service = GTFS.get_service(agency: agency, remote_id: "1")

    assert %Service{
             monday: false,
             tuesday: false,
             wednesday: false,
             thursday: false,
             friday: false,
             saturday: true,
             sunday: false,
             start_date: ~D[2015-02-22],
             end_date: ~D[2015-06-30]
           } = service
  end

  test "it imports the correct number of service exceptions", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)
    [agency] = GTFS.list_agencies()
    service = GTFS.get_service(agency: agency, remote_id: "2")

    assert 1 == length(GTFS.list_service_exceptions(agency: agency, service: service))
  end

  test "it imports a service exception correctly", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)

    [agency] = GTFS.list_agencies()
    service = GTFS.get_service(agency: agency, remote_id: "2")
    [service_exception] = GTFS.list_service_exceptions(agency: agency, service: service)

    assert %ServiceException{
      date: ~D[2015-05-25],
      exception: 1
    } = service_exception
  end
end
