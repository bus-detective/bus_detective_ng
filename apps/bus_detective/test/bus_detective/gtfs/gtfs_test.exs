defmodule BusDetective.GTFSTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS

  describe "agencies" do
    alias BusDetective.GTFS.Agency

    @valid_attrs %{display_name: "some display_name", fare_url: "some fare_url", gtfs_endpoint: "some gtfs_endpoint", gtfs_service_alerts_url: "some gtfs_service_alerts_url", gtfs_trip_updates_url: "some gtfs_trip_updates_url", gtfs_vehicle_positions_url: "some gtfs_vehicle_positions_url", language: "some language", name: "some name", phone: "some phone", remote_id: "some remote_id", timezone: "some timezone", url: "some url"}
    @update_attrs %{display_name: "some updated display_name", fare_url: "some updated fare_url", gtfs_endpoint: "some updated gtfs_endpoint", gtfs_service_alerts_url: "some updated gtfs_service_alerts_url", gtfs_trip_updates_url: "some updated gtfs_trip_updates_url", gtfs_vehicle_positions_url: "some updated gtfs_vehicle_positions_url", language: "some updated language", name: "some updated name", phone: "some updated phone", remote_id: "some updated remote_id", timezone: "some updated timezone", url: "some updated url"}
    @invalid_attrs %{display_name: nil, fare_url: nil, gtfs_endpoint: nil, gtfs_service_alerts_url: nil, gtfs_trip_updates_url: nil, gtfs_vehicle_positions_url: nil, language: nil, name: nil, phone: nil, remote_id: nil, timezone: nil, url: nil}

    def agency_fixture(attrs \\ %{}) do
      {:ok, agency} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_agency()

      agency
    end

    test "list_agencies/0 returns all agencies" do
      agency = agency_fixture()
      assert GTFS.list_agencies() == [agency]
    end

    test "get_agency!/1 returns the agency with given id" do
      agency = agency_fixture()
      assert GTFS.get_agency!(agency.id) == agency
    end

    test "create_agency/1 with valid data creates a agency" do
      assert {:ok, %Agency{} = agency} = GTFS.create_agency(@valid_attrs)
      assert agency.display_name == "some display_name"
      assert agency.fare_url == "some fare_url"
      assert agency.gtfs_endpoint == "some gtfs_endpoint"
      assert agency.gtfs_service_alerts_url == "some gtfs_service_alerts_url"
      assert agency.gtfs_trip_updates_url == "some gtfs_trip_updates_url"
      assert agency.gtfs_vehicle_positions_url == "some gtfs_vehicle_positions_url"
      assert agency.language == "some language"
      assert agency.name == "some name"
      assert agency.phone == "some phone"
      assert agency.remote_id == "some remote_id"
      assert agency.timezone == "some timezone"
      assert agency.url == "some url"
    end

    test "create_agency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_agency(@invalid_attrs)
    end

    test "update_agency/2 with valid data updates the agency" do
      agency = agency_fixture()
      assert {:ok, agency} = GTFS.update_agency(agency, @update_attrs)
      assert %Agency{} = agency
      assert agency.display_name == "some updated display_name"
      assert agency.fare_url == "some updated fare_url"
      assert agency.gtfs_endpoint == "some updated gtfs_endpoint"
      assert agency.gtfs_service_alerts_url == "some updated gtfs_service_alerts_url"
      assert agency.gtfs_trip_updates_url == "some updated gtfs_trip_updates_url"
      assert agency.gtfs_vehicle_positions_url == "some updated gtfs_vehicle_positions_url"
      assert agency.language == "some updated language"
      assert agency.name == "some updated name"
      assert agency.phone == "some updated phone"
      assert agency.remote_id == "some updated remote_id"
      assert agency.timezone == "some updated timezone"
      assert agency.url == "some updated url"
    end

    test "update_agency/2 with invalid data returns error changeset" do
      agency = agency_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_agency(agency, @invalid_attrs)
      assert agency == GTFS.get_agency!(agency.id)
    end

    test "delete_agency/1 deletes the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{}} = GTFS.delete_agency(agency)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_agency!(agency.id) end
    end

    test "change_agency/1 returns a agency changeset" do
      agency = agency_fixture()
      assert %Ecto.Changeset{} = GTFS.change_agency(agency)
    end
  end

  describe "services" do
    alias BusDetective.GTFS.Service

    @valid_attrs %{agency_id: 42, end_date: ~D[2010-04-17], friday: true, monday: true, remote_id: "some remote_id", saturday: true, start_date: ~D[2010-04-17], sunday: true, thursday: true, tuesday: true, wednesday: true}
    @update_attrs %{agency_id: 43, end_date: ~D[2011-05-18], friday: false, monday: false, remote_id: "some updated remote_id", saturday: false, start_date: ~D[2011-05-18], sunday: false, thursday: false, tuesday: false, wednesday: false}
    @invalid_attrs %{agency_id: nil, end_date: nil, friday: nil, monday: nil, remote_id: nil, saturday: nil, start_date: nil, sunday: nil, thursday: nil, tuesday: nil, wednesday: nil}

    def service_fixture(attrs \\ %{}) do
      {:ok, service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_service()

      service
    end

    test "list_services/0 returns all services" do
      service = service_fixture()
      assert GTFS.list_services() == [service]
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert GTFS.get_service!(service.id) == service
    end

    test "create_service/1 with valid data creates a service" do
      assert {:ok, %Service{} = service} = GTFS.create_service(@valid_attrs)
      assert service.agency_id == 42
      assert service.end_date == ~D[2010-04-17]
      assert service.friday == true
      assert service.monday == true
      assert service.remote_id == "some remote_id"
      assert service.saturday == true
      assert service.start_date == ~D[2010-04-17]
      assert service.sunday == true
      assert service.thursday == true
      assert service.tuesday == true
      assert service.wednesday == true
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      assert {:ok, service} = GTFS.update_service(service, @update_attrs)
      assert %Service{} = service
      assert service.agency_id == 43
      assert service.end_date == ~D[2011-05-18]
      assert service.friday == false
      assert service.monday == false
      assert service.remote_id == "some updated remote_id"
      assert service.saturday == false
      assert service.start_date == ~D[2011-05-18]
      assert service.sunday == false
      assert service.thursday == false
      assert service.tuesday == false
      assert service.wednesday == false
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_service(service, @invalid_attrs)
      assert service == GTFS.get_service!(service.id)
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = GTFS.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = GTFS.change_service(service)
    end
  end

  describe "service_exceptions" do
    alias BusDetective.GTFS.ServiceException

    @valid_attrs %{agency_id: 42, date: ~D[2010-04-17], exception: 42, service_id: 42}
    @update_attrs %{agency_id: 43, date: ~D[2011-05-18], exception: 43, service_id: 43}
    @invalid_attrs %{agency_id: nil, date: nil, exception: nil, service_id: nil}

    def service_exception_fixture(attrs \\ %{}) do
      {:ok, service_exception} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_service_exception()

      service_exception
    end

    test "list_service_exceptions/0 returns all service_exceptions" do
      service_exception = service_exception_fixture()
      assert GTFS.list_service_exceptions() == [service_exception]
    end

    test "get_service_exception!/1 returns the service_exception with given id" do
      service_exception = service_exception_fixture()
      assert GTFS.get_service_exception!(service_exception.id) == service_exception
    end

    test "create_service_exception/1 with valid data creates a service_exception" do
      assert {:ok, %ServiceException{} = service_exception} = GTFS.create_service_exception(@valid_attrs)
      assert service_exception.agency_id == 42
      assert service_exception.date == ~D[2010-04-17]
      assert service_exception.exception == 42
      assert service_exception.service_id == 42
    end

    test "create_service_exception/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_service_exception(@invalid_attrs)
    end

    test "update_service_exception/2 with valid data updates the service_exception" do
      service_exception = service_exception_fixture()
      assert {:ok, service_exception} = GTFS.update_service_exception(service_exception, @update_attrs)
      assert %ServiceException{} = service_exception
      assert service_exception.agency_id == 43
      assert service_exception.date == ~D[2011-05-18]
      assert service_exception.exception == 43
      assert service_exception.service_id == 43
    end

    test "update_service_exception/2 with invalid data returns error changeset" do
      service_exception = service_exception_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_service_exception(service_exception, @invalid_attrs)
      assert service_exception == GTFS.get_service_exception!(service_exception.id)
    end

    test "delete_service_exception/1 deletes the service_exception" do
      service_exception = service_exception_fixture()
      assert {:ok, %ServiceException{}} = GTFS.delete_service_exception(service_exception)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_service_exception!(service_exception.id) end
    end

    test "change_service_exception/1 returns a service_exception changeset" do
      service_exception = service_exception_fixture()
      assert %Ecto.Changeset{} = GTFS.change_service_exception(service_exception)
    end
  end

  describe "routes" do
    alias BusDetective.GTFS.Route

    @valid_attrs %{agency_id: 42, color: "some color", description: "some description", long_name: "some long_name", remote_id: "some remote_id", route_type: "some route_type", short_name: "some short_name", text_color: "some text_color", url: "some url"}
    @update_attrs %{agency_id: 43, color: "some updated color", description: "some updated description", long_name: "some updated long_name", remote_id: "some updated remote_id", route_type: "some updated route_type", short_name: "some updated short_name", text_color: "some updated text_color", url: "some updated url"}
    @invalid_attrs %{agency_id: nil, color: nil, description: nil, long_name: nil, remote_id: nil, route_type: nil, short_name: nil, text_color: nil, url: nil}

    def route_fixture(attrs \\ %{}) do
      {:ok, route} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_route()

      route
    end

    test "list_routes/0 returns all routes" do
      route = route_fixture()
      assert GTFS.list_routes() == [route]
    end

    test "get_route!/1 returns the route with given id" do
      route = route_fixture()
      assert GTFS.get_route!(route.id) == route
    end

    test "create_route/1 with valid data creates a route" do
      assert {:ok, %Route{} = route} = GTFS.create_route(@valid_attrs)
      assert route.agency_id == 42
      assert route.color == "some color"
      assert route.description == "some description"
      assert route.long_name == "some long_name"
      assert route.remote_id == "some remote_id"
      assert route.route_type == "some route_type"
      assert route.short_name == "some short_name"
      assert route.text_color == "some text_color"
      assert route.url == "some url"
    end

    test "create_route/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_route(@invalid_attrs)
    end

    test "update_route/2 with valid data updates the route" do
      route = route_fixture()
      assert {:ok, route} = GTFS.update_route(route, @update_attrs)
      assert %Route{} = route
      assert route.agency_id == 43
      assert route.color == "some updated color"
      assert route.description == "some updated description"
      assert route.long_name == "some updated long_name"
      assert route.remote_id == "some updated remote_id"
      assert route.route_type == "some updated route_type"
      assert route.short_name == "some updated short_name"
      assert route.text_color == "some updated text_color"
      assert route.url == "some updated url"
    end

    test "update_route/2 with invalid data returns error changeset" do
      route = route_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_route(route, @invalid_attrs)
      assert route == GTFS.get_route!(route.id)
    end

    test "delete_route/1 deletes the route" do
      route = route_fixture()
      assert {:ok, %Route{}} = GTFS.delete_route(route)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_route!(route.id) end
    end

    test "change_route/1 returns a route changeset" do
      route = route_fixture()
      assert %Ecto.Changeset{} = GTFS.change_route(route)
    end
  end

  describe "stops" do
    alias BusDetective.GTFS.Stop

    @valid_attrs %{agency_id: 42, code: 42, description: "some description", latitude: 120.5, location_type: 42, longitude: 120.5, name: "some name", parent_station: "some parent_station", remote_id: "some remote_id", url: "some url", zone_id: 42}
    @update_attrs %{agency_id: 43, code: 43, description: "some updated description", latitude: 456.7, location_type: 43, longitude: 456.7, name: "some updated name", parent_station: "some updated parent_station", remote_id: "some updated remote_id", url: "some updated url", zone_id: 43}
    @invalid_attrs %{agency_id: nil, code: nil, description: nil, latitude: nil, location_type: nil, longitude: nil, name: nil, parent_station: nil, remote_id: nil, url: nil, zone_id: nil}

    def stop_fixture(attrs \\ %{}) do
      {:ok, stop} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_stop()

      stop
    end

    test "list_stops/0 returns all stops" do
      stop = stop_fixture()
      assert GTFS.list_stops() == [stop]
    end

    test "get_stop!/1 returns the stop with given id" do
      stop = stop_fixture()
      assert GTFS.get_stop!(stop.id) == stop
    end

    test "create_stop/1 with valid data creates a stop" do
      assert {:ok, %Stop{} = stop} = GTFS.create_stop(@valid_attrs)
      assert stop.agency_id == 42
      assert stop.code == 42
      assert stop.description == "some description"
      assert stop.latitude == 120.5
      assert stop.location_type == 42
      assert stop.longitude == 120.5
      assert stop.name == "some name"
      assert stop.parent_station == "some parent_station"
      assert stop.remote_id == "some remote_id"
      assert stop.url == "some url"
      assert stop.zone_id == 42
    end

    test "create_stop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_stop(@invalid_attrs)
    end

    test "update_stop/2 with valid data updates the stop" do
      stop = stop_fixture()
      assert {:ok, stop} = GTFS.update_stop(stop, @update_attrs)
      assert %Stop{} = stop
      assert stop.agency_id == 43
      assert stop.code == 43
      assert stop.description == "some updated description"
      assert stop.latitude == 456.7
      assert stop.location_type == 43
      assert stop.longitude == 456.7
      assert stop.name == "some updated name"
      assert stop.parent_station == "some updated parent_station"
      assert stop.remote_id == "some updated remote_id"
      assert stop.url == "some updated url"
      assert stop.zone_id == 43
    end

    test "update_stop/2 with invalid data returns error changeset" do
      stop = stop_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_stop(stop, @invalid_attrs)
      assert stop == GTFS.get_stop!(stop.id)
    end

    test "delete_stop/1 deletes the stop" do
      stop = stop_fixture()
      assert {:ok, %Stop{}} = GTFS.delete_stop(stop)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_stop!(stop.id) end
    end

    test "change_stop/1 returns a stop changeset" do
      stop = stop_fixture()
      assert %Ecto.Changeset{} = GTFS.change_stop(stop)
    end
  end

  describe "stops" do
    alias BusDetective.GTFS.Stop

    @valid_attrs %{agency_id: 42, code: 42, description: "some description", latitude: 120.5, location_type: 42, longitude: 120.5, name: "some name", parent_station: "some parent_station", remote_id: "some remote_id", timezone: "some timezone", url: "some url", wheelchair_boarding: 42, zone_id: 42}
    @update_attrs %{agency_id: 43, code: 43, description: "some updated description", latitude: 456.7, location_type: 43, longitude: 456.7, name: "some updated name", parent_station: "some updated parent_station", remote_id: "some updated remote_id", timezone: "some updated timezone", url: "some updated url", wheelchair_boarding: 43, zone_id: 43}
    @invalid_attrs %{agency_id: nil, code: nil, description: nil, latitude: nil, location_type: nil, longitude: nil, name: nil, parent_station: nil, remote_id: nil, timezone: nil, url: nil, wheelchair_boarding: nil, zone_id: nil}

    def stop_fixture(attrs \\ %{}) do
      {:ok, stop} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_stop()

      stop
    end

    test "list_stops/0 returns all stops" do
      stop = stop_fixture()
      assert GTFS.list_stops() == [stop]
    end

    test "get_stop!/1 returns the stop with given id" do
      stop = stop_fixture()
      assert GTFS.get_stop!(stop.id) == stop
    end

    test "create_stop/1 with valid data creates a stop" do
      assert {:ok, %Stop{} = stop} = GTFS.create_stop(@valid_attrs)
      assert stop.agency_id == 42
      assert stop.code == 42
      assert stop.description == "some description"
      assert stop.latitude == 120.5
      assert stop.location_type == 42
      assert stop.longitude == 120.5
      assert stop.name == "some name"
      assert stop.parent_station == "some parent_station"
      assert stop.remote_id == "some remote_id"
      assert stop.timezone == "some timezone"
      assert stop.url == "some url"
      assert stop.wheelchair_boarding == 42
      assert stop.zone_id == 42
    end

    test "create_stop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_stop(@invalid_attrs)
    end

    test "update_stop/2 with valid data updates the stop" do
      stop = stop_fixture()
      assert {:ok, stop} = GTFS.update_stop(stop, @update_attrs)
      assert %Stop{} = stop
      assert stop.agency_id == 43
      assert stop.code == 43
      assert stop.description == "some updated description"
      assert stop.latitude == 456.7
      assert stop.location_type == 43
      assert stop.longitude == 456.7
      assert stop.name == "some updated name"
      assert stop.parent_station == "some updated parent_station"
      assert stop.remote_id == "some updated remote_id"
      assert stop.timezone == "some updated timezone"
      assert stop.url == "some updated url"
      assert stop.wheelchair_boarding == 43
      assert stop.zone_id == 43
    end

    test "update_stop/2 with invalid data returns error changeset" do
      stop = stop_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_stop(stop, @invalid_attrs)
      assert stop == GTFS.get_stop!(stop.id)
    end

    test "delete_stop/1 deletes the stop" do
      stop = stop_fixture()
      assert {:ok, %Stop{}} = GTFS.delete_stop(stop)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_stop!(stop.id) end
    end

    test "change_stop/1 returns a stop changeset" do
      stop = stop_fixture()
      assert %Ecto.Changeset{} = GTFS.change_stop(stop)
    end
  end

  describe "shapes" do
    alias BusDetective.GTFS.Shape

    @valid_attrs %{agency_id: 42, geometry: "some geometry", remote_id: "some remote_id"}
    @update_attrs %{agency_id: 43, geometry: "some updated geometry", remote_id: "some updated remote_id"}
    @invalid_attrs %{agency_id: nil, geometry: nil, remote_id: nil}

    def shape_fixture(attrs \\ %{}) do
      {:ok, shape} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_shape()

      shape
    end

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert GTFS.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert GTFS.get_shape!(shape.id) == shape
    end

    test "create_shape/1 with valid data creates a shape" do
      assert {:ok, %Shape{} = shape} = GTFS.create_shape(@valid_attrs)
      assert shape.agency_id == 42
      assert shape.geometry == "some geometry"
      assert shape.remote_id == "some remote_id"
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_shape(@invalid_attrs)
    end

    test "update_shape/2 with valid data updates the shape" do
      shape = shape_fixture()
      assert {:ok, shape} = GTFS.update_shape(shape, @update_attrs)
      assert %Shape{} = shape
      assert shape.agency_id == 43
      assert shape.geometry == "some updated geometry"
      assert shape.remote_id == "some updated remote_id"
    end

    test "update_shape/2 with invalid data returns error changeset" do
      shape = shape_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_shape(shape, @invalid_attrs)
      assert shape == GTFS.get_shape!(shape.id)
    end

    test "delete_shape/1 deletes the shape" do
      shape = shape_fixture()
      assert {:ok, %Shape{}} = GTFS.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_shape!(shape.id) end
    end

    test "change_shape/1 returns a shape changeset" do
      shape = shape_fixture()
      assert %Ecto.Changeset{} = GTFS.change_shape(shape)
    end
  end

  describe "trips" do
    alias BusDetective.GTFS.Trip

    @valid_attrs %{agency_id: 42, bikes_allowed: 42, block_id: 42, direction_id: 42, headsign: "some headsign", remote_id: "some remote_id", route_id: 42, service_id: 42, shape_id: 42, short_name: "some short_name", wheelchair_accessible: 42}
    @update_attrs %{agency_id: 43, bikes_allowed: 43, block_id: 43, direction_id: 43, headsign: "some updated headsign", remote_id: "some updated remote_id", route_id: 43, service_id: 43, shape_id: 43, short_name: "some updated short_name", wheelchair_accessible: 43}
    @invalid_attrs %{agency_id: nil, bikes_allowed: nil, block_id: nil, direction_id: nil, headsign: nil, remote_id: nil, route_id: nil, service_id: nil, shape_id: nil, short_name: nil, wheelchair_accessible: nil}

    def trip_fixture(attrs \\ %{}) do
      {:ok, trip} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_trip()

      trip
    end

    test "list_trips/0 returns all trips" do
      trip = trip_fixture()
      assert GTFS.list_trips() == [trip]
    end

    test "get_trip!/1 returns the trip with given id" do
      trip = trip_fixture()
      assert GTFS.get_trip!(trip.id) == trip
    end

    test "create_trip/1 with valid data creates a trip" do
      assert {:ok, %Trip{} = trip} = GTFS.create_trip(@valid_attrs)
      assert trip.agency_id == 42
      assert trip.bikes_allowed == 42
      assert trip.block_id == 42
      assert trip.direction_id == 42
      assert trip.headsign == "some headsign"
      assert trip.remote_id == "some remote_id"
      assert trip.route_id == 42
      assert trip.service_id == 42
      assert trip.shape_id == 42
      assert trip.short_name == "some short_name"
      assert trip.wheelchair_accessible == 42
    end

    test "create_trip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_trip(@invalid_attrs)
    end

    test "update_trip/2 with valid data updates the trip" do
      trip = trip_fixture()
      assert {:ok, trip} = GTFS.update_trip(trip, @update_attrs)
      assert %Trip{} = trip
      assert trip.agency_id == 43
      assert trip.bikes_allowed == 43
      assert trip.block_id == 43
      assert trip.direction_id == 43
      assert trip.headsign == "some updated headsign"
      assert trip.remote_id == "some updated remote_id"
      assert trip.route_id == 43
      assert trip.service_id == 43
      assert trip.shape_id == 43
      assert trip.short_name == "some updated short_name"
      assert trip.wheelchair_accessible == 43
    end

    test "update_trip/2 with invalid data returns error changeset" do
      trip = trip_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_trip(trip, @invalid_attrs)
      assert trip == GTFS.get_trip!(trip.id)
    end

    test "delete_trip/1 deletes the trip" do
      trip = trip_fixture()
      assert {:ok, %Trip{}} = GTFS.delete_trip(trip)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_trip!(trip.id) end
    end

    test "change_trip/1 returns a trip changeset" do
      trip = trip_fixture()
      assert %Ecto.Changeset{} = GTFS.change_trip(trip)
    end
  end

  describe "stop_times" do
    alias BusDetective.GTFS.StopTime

    @valid_attrs %{agency_id: 42, arrival_time: 42, departure_time: 42, drop_off_type: 42, pickup_type: 42, shape_dist_traveled: 120.5, stop_headsign: "some stop_headsign", stop_id: 42, stop_sequence: 42, trip_id: 42}
    @update_attrs %{agency_id: 43, arrival_time: 43, departure_time: 43, drop_off_type: 43, pickup_type: 43, shape_dist_traveled: 456.7, stop_headsign: "some updated stop_headsign", stop_id: 43, stop_sequence: 43, trip_id: 43}
    @invalid_attrs %{agency_id: nil, arrival_time: nil, departure_time: nil, drop_off_type: nil, pickup_type: nil, shape_dist_traveled: nil, stop_headsign: nil, stop_id: nil, stop_sequence: nil, trip_id: nil}

    def stop_time_fixture(attrs \\ %{}) do
      {:ok, stop_time} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GTFS.create_stop_time()

      stop_time
    end

    test "list_stop_times/0 returns all stop_times" do
      stop_time = stop_time_fixture()
      assert GTFS.list_stop_times() == [stop_time]
    end

    test "get_stop_time!/1 returns the stop_time with given id" do
      stop_time = stop_time_fixture()
      assert GTFS.get_stop_time!(stop_time.id) == stop_time
    end

    test "create_stop_time/1 with valid data creates a stop_time" do
      assert {:ok, %StopTime{} = stop_time} = GTFS.create_stop_time(@valid_attrs)
      assert stop_time.agency_id == 42
      assert stop_time.arrival_time == 42
      assert stop_time.departure_time == 42
      assert stop_time.drop_off_type == 42
      assert stop_time.pickup_type == 42
      assert stop_time.shape_dist_traveled == 120.5
      assert stop_time.stop_headsign == "some stop_headsign"
      assert stop_time.stop_id == 42
      assert stop_time.stop_sequence == 42
      assert stop_time.trip_id == 42
    end

    test "create_stop_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GTFS.create_stop_time(@invalid_attrs)
    end

    test "update_stop_time/2 with valid data updates the stop_time" do
      stop_time = stop_time_fixture()
      assert {:ok, stop_time} = GTFS.update_stop_time(stop_time, @update_attrs)
      assert %StopTime{} = stop_time
      assert stop_time.agency_id == 43
      assert stop_time.arrival_time == 43
      assert stop_time.departure_time == 43
      assert stop_time.drop_off_type == 43
      assert stop_time.pickup_type == 43
      assert stop_time.shape_dist_traveled == 456.7
      assert stop_time.stop_headsign == "some updated stop_headsign"
      assert stop_time.stop_id == 43
      assert stop_time.stop_sequence == 43
      assert stop_time.trip_id == 43
    end

    test "update_stop_time/2 with invalid data returns error changeset" do
      stop_time = stop_time_fixture()
      assert {:error, %Ecto.Changeset{}} = GTFS.update_stop_time(stop_time, @invalid_attrs)
      assert stop_time == GTFS.get_stop_time!(stop_time.id)
    end

    test "delete_stop_time/1 deletes the stop_time" do
      stop_time = stop_time_fixture()
      assert {:ok, %StopTime{}} = GTFS.delete_stop_time(stop_time)
      assert_raise Ecto.NoResultsError, fn -> GTFS.get_stop_time!(stop_time.id) end
    end

    test "change_stop_time/1 returns a stop_time changeset" do
      stop_time = stop_time_fixture()
      assert %Ecto.Changeset{} = GTFS.change_stop_time(stop_time)
    end
  end
end
