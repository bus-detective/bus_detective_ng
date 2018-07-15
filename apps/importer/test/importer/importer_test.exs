defmodule Importer.ImporterTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Interval, Route, Service, ServiceException, Shape, Stop, StopTime, Trip}

  setup do
    gtfs_file = Path.join(File.cwd!(), "test/fixtures/google_transit_info.zip")
    {:ok, gtfs_file: gtfs_file}
  end

  test "it imports the correct number of agencies", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    assert 1 == length(GTFS.list_agencies())
  end

  test "it imports the agency correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

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
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 3 == length(GTFS.list_services(agency))
  end

  test "it imports a service correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    service = GTFS.get_service(agency, "1")

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
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()
    service = GTFS.get_service(agency, "1")

    assert 1 == length(GTFS.list_service_exceptions(agency, service))
  end

  test "it imports a service exception correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    service = GTFS.get_service(agency, "1")
    [service_exception] = GTFS.list_service_exceptions(agency, service)

    assert %ServiceException{
             date: ~D[2015-05-25],
             exception: 1
           } = service_exception
  end

  test "it imports the correct number of routes", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 10 == length(GTFS.list_routes(agency))
  end

  test "it imports a route correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    route = GTFS.get_route(agency, "1")

    assert %Route{
             short_name: "1",
             long_name: "Museum Center Mt. Adams Eden Park",
             route_type: "3",
             color: "FF4AFF",
             text_color: "FFFFFF"
           } = route
  end

  test "it imports the correct number of stops", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 10 == length(GTFS.list_stops(agency))
  end

  test "it imports a stop correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    stop = GTFS.get_stop(agency, "EZZLINe")

    assert %Stop{
             code: 4451,
             name: "Ezzard Charles Dr & Linn St",
             latitude: 39.109286,
             longitude: -84.527882
           } = stop
  end

  test "it imports the correct number of shapes", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 1 == length(GTFS.list_shapes(agency))
  end

  test "it imports a shape correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    shape = GTFS.get_shape(agency, "83146")

    assert %Shape{
             geometry: %Geo.LineString{
               srid: 4326,
               coordinates: [
                 {39.109414, -84.536507},
                 {39.109431, -84.536437},
                 {39.109467, -84.536356},
                 {39.109530, -84.536274},
                 {39.109583, -84.536181},
                 {39.109610, -84.536088},
                 {39.109628, -84.535959},
                 {39.109628, -84.535807},
                 {39.109455, -84.532203},
                 {39.109423, -84.531868}
               ]
             }
           } = shape
  end

  test "it imports the correct number of trips", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 10 == length(GTFS.list_trips(agency))
  end

  test "it imports a trip correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    %Route{id: route_id} = GTFS.get_route(agency, "1")
    %Service{id: service_id} = GTFS.get_service(agency, "1")
    %Shape{id: shape_id} = GTFS.get_shape(agency, "83146")

    trip = GTFS.get_trip(agency, "955305")

    assert %Trip{
             route_id: ^route_id,
             service_id: ^service_id,
             shape_id: ^shape_id,
             headsign: "Mt Adams - Eden Park",
             block_id: 125_647
           } = trip
  end

  test "it imports the correct number of stop times", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)
    [agency] = GTFS.list_agencies()

    assert 10 == length(GTFS.list_stop_times(agency))
  end

  test "it imports a stop time correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file(gtfs_file)

    [agency] = GTFS.list_agencies()
    stop = GTFS.get_stop(agency, "EZZLINw")
    trip = GTFS.get_trip(agency, "955305")

    stop_time = GTFS.get_stop_time(agency, stop, 2, trip)

    assert %StopTime{
             shape_dist_traveled: 0.3616,
             arrival_time: %Interval{hours: 22, minutes: 10, seconds: 57},
             departure_time: %Interval{hours: 22, minutes: 10, seconds: 57}
           } = stop_time
  end

  describe "departure calculation" do
    test "it calculates agency timezone stop times correctly", %{gtfs_file: gtfs_file} do
      Importer.import_from_file(gtfs_file)
      [agency] = GTFS.list_agencies()
      stop = GTFS.get_stop(agency, "EZZLINw")
      trip = GTFS.get_trip(agency, "955305")
      stop_time = GTFS.get_stop_time(agency, stop, 2, trip)
      {:ok, start_time} = Timex.parse("2015-06-06 22:01:00-04:00", "{ISO:Extended}")
      {:ok, end_time} = Timex.parse("2015-06-06 23:01:00-04:00", "{ISO:Extended}")

      result = GTFS.projected_stop_times_for_stop(stop, start_time, end_time)

      assert 1 == Enum.count(result)
      assert stop_time.id == Enum.at(result, 0).stop_time_id
    end

    test "it calculates utc stop times correctly", %{gtfs_file: gtfs_file} do
      Importer.import_from_file(gtfs_file)
      [agency] = GTFS.list_agencies()
      stop = GTFS.get_stop(agency, "EZZLINw")
      trip = GTFS.get_trip(agency, "955305")
      stop_time = GTFS.get_stop_time(agency, stop, 2, trip)
      {:ok, start_time} = Timex.parse("2015-06-07 02:01:00-0000", "{ISO:Extended}")
      {:ok, end_time} = Timex.parse("2015-06-07 03:01:00-0000", "{ISO:Extended}")

      result = GTFS.projected_stop_times_for_stop(stop, start_time, end_time)

      assert 1 == Enum.count(result)
      assert stop_time.id == Enum.at(result, 0).stop_time_id
    end

    test "it handles service exceptions correctly", %{gtfs_file: gtfs_file} do
      Importer.import_from_file(gtfs_file)
      [agency] = GTFS.list_agencies()
      stop = GTFS.get_stop(agency, "EZZLINw")
      trip = GTFS.get_trip(agency, "955305")
      stop_time = GTFS.get_stop_time(agency, stop, 2, trip)
      {:ok, start_time} = Timex.parse("2015-05-26 02:01:00-0000", "{ISO:Extended}")
      {:ok, end_time} = Timex.parse("2015-05-26 03:01:00-0000", "{ISO:Extended}")

      result = GTFS.projected_stop_times_for_stop(stop, start_time, end_time)

      assert 1 == Enum.count(result)
      assert stop_time.id == Enum.at(result, 0).stop_time_id
    end
  end
end
