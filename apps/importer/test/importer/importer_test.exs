defmodule Importer.ImporterTest do
  use BusDetective.DataCase

  import Ecto.Query

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Feed, Interval, Route, Service, ServiceException, Shape, Stop, StopTime, Trip}
  alias BusDetective.Repo

  setup do
    gtfs_file = Path.join(File.cwd!(), "test/fixtures/google_transit_info.zip")
    updated_gtfs_file = Path.join(File.cwd!(), "test/fixtures/updated_google_transit_info.zip")
    {:ok, gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file}
  end

  test "it performs a partial update when the schedule file hasn't changed", %{gtfs_file: gtfs_file} do
    assert {:ok, :full_update} = Importer.import_from_file("TEST", gtfs_file)
    assert {:ok, :partial_update} = Importer.import_from_file("TEST", gtfs_file)
  end

  test "it imports the correct number of agencies", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    assert 1 == length(Repo.all(from(agency in Agency)))
  end

  test "it upserts the agency on subsequent import", %{gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [%Agency{id: id}] = Repo.all(from(agency in Agency))

    Importer.import_from_file("TEST", updated_gtfs_file)
    assert [%Agency{id: ^id, name: "Updated"}] = Repo.all(from(agency in Agency))
  end

  test "it imports the agency correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    feed = Repo.all(from(agency in Agency)) |> List.first()

    assert %Agency{
             fare_url: "http://www.go-metro.com/fares-passes",
             remote_id: "SORTA",
             language: "en",
             name: "Southwest Ohio Regional Transit Authority",
             phone: "513-621-4455",
             timezone: "America/Detroit",
             url: "http://www.go-metro.com"
           } = feed
  end

  test "it imports the correct number of services", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 6 == length(Repo.all(from(s in Service, where: s.feed_id == ^feed.id)))
  end

  test "it upserts the services on subsequent import", %{gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    %Service{id: id, monday: false} = Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))

    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert %Service{id: ^id, monday: true} =
             Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))
  end

  test "it imports a service correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    service = Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))

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
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    service = Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))

    assert 1 ==
             length(
               Repo.all(from(se in ServiceException, where: se.feed_id == ^feed.id and se.service_id == ^service.id))
             )
  end

  test "it re-imports the correct number of service exceptions on subsequent import", %{
    gtfs_file: gtfs_file,
    updated_gtfs_file: updated_gtfs_file
  } do
    Importer.import_from_file("TEST", gtfs_file)
    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    service = Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))

    assert 1 ==
             length(
               Repo.all(from(se in ServiceException, where: se.feed_id == ^feed.id and se.service_id == ^service.id))
             )
  end

  test "it imports a service exception correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    service = Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))

    [service_exception] =
      Repo.all(from(se in ServiceException, where: se.feed_id == ^feed.id and se.service_id == ^service.id))

    assert %ServiceException{
             date: ~D[2015-05-25],
             exception: 1
           } = service_exception
  end

  test "it imports the correct number of routes", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 10 == length(Repo.all(from(r in Route, where: r.feed_id == ^feed.id)))
  end

  test "it upserts the routes on subsequent import", %{gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    %Route{id: id} = Repo.one(from(r in Route, where: r.feed_id == ^feed.id and r.remote_id == ^"1"))

    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert %Route{id: ^id, long_name: "Updated"} =
             Repo.one(from(r in Route, where: r.feed_id == ^feed.id and r.remote_id == ^"1"))
  end

  test "it imports a route correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    route = Repo.one(from(r in Route, where: r.feed_id == ^feed.id and r.remote_id == ^"1"))

    assert %Route{
             short_name: "1",
             long_name: "Museum Center Mt. Adams Eden Park",
             route_type: "3",
             color: "FF4AFF",
             text_color: "FFFFFF"
           } = route
  end

  test "it imports the correct number of stops", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 10 == length(Repo.all(from(s in Stop, where: s.feed_id == ^feed.id)))
  end

  test "it upserts the stops on subsequent import", %{gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    %Stop{id: id} = Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINe"))

    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert %Stop{id: ^id, name: "Updated"} =
             Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINe"))
  end

  test "it imports a stop correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    stop = Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINe"))

    assert %Stop{
             code: 4451,
             name: "Ezzard Charles Dr & Linn St",
             location: %Geo.Point{
               coordinates: {-84.527882, 39.109286},
               srid: 4326
             }
           } = stop
  end

  test "it imports the correct number of shapes", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 1 == length(Repo.all(from(s in Shape, where: s.feed_id == ^feed.id)))
  end

  test "it upserts the shapes on subsequent import", %{gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    %Shape{id: id} = Repo.one(from(s in Shape, where: s.feed_id == ^feed.id and s.remote_id == ^"83146"))

    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    assert %Shape{id: ^id} = Repo.one(from(s in Shape, where: s.feed_id == ^feed.id and s.remote_id == ^"83146"))
  end

  test "it imports a shape correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    shape = Repo.one(from(s in Shape, where: s.feed_id == ^feed.id and s.remote_id == ^"83146"))

    assert %Shape{
             geometry: %Geo.LineString{
               srid: 4326,
               coordinates: [
                 {-84.536507, 39.109414},
                 {-84.536437, 39.109431},
                 {-84.536356, 39.109467},
                 {-84.536274, 39.109530},
                 {-84.536181, 39.109583},
                 {-84.536088, 39.109610},
                 {-84.535959, 39.109628},
                 {-84.535807, 39.109628},
                 {-84.532203, 39.109455},
                 {-84.531868, 39.109423}
               ]
             }
           } = shape
  end

  test "it imports the correct number of trips", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 20 == length(Repo.all(from(t in Trip, where: t.feed_id == ^feed.id)))
  end

  test "it upserts the trips on subsequent import", %{gtfs_file: gtfs_file, updated_gtfs_file: updated_gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))
    %Trip{id: id} = Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))

    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert %Trip{id: ^id, headsign: "Updated"} =
             Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))
  end

  test "it imports a trip correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    %Route{id: route_id} = Repo.one(from(r in Route, where: r.feed_id == ^feed.id and r.remote_id == ^"1"))
    %Service{id: service_id} = Repo.one(from(s in Service, where: s.feed_id == ^feed.id and s.remote_id == ^"1"))
    %Shape{id: shape_id} = Repo.one(from(s in Shape, where: s.feed_id == ^feed.id and s.remote_id == ^"83146"))

    trip = Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))

    assert %Trip{
             route_id: ^route_id,
             service_id: ^service_id,
             shape_id: ^shape_id,
             headsign: "Mt Adams - Eden Park",
             block_id: "125647"
           } = trip
  end

  test "it imports the correct number of stop times", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 20 == length(Repo.all(from(st in StopTime, where: st.feed_id == ^feed.id)))
  end

  test "it re-imports the correct number of stop times on subsequent import", %{
    gtfs_file: gtfs_file,
    updated_gtfs_file: updated_gtfs_file
  } do
    Importer.import_from_file("TEST", gtfs_file)
    Importer.import_from_file("TEST", updated_gtfs_file)
    [feed] = Repo.all(from(feed in Feed))

    assert 10 == length(Repo.all(from(st in StopTime, where: st.feed_id == ^feed.id)))
  end

  test "it imports a stop time correctly", %{gtfs_file: gtfs_file} do
    Importer.import_from_file("TEST", gtfs_file)

    [feed] = Repo.all(from(feed in Feed))
    stop = Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINw"))
    trip = Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))

    stop_time =
      Repo.one(
        from(
          st in StopTime,
          where: st.feed_id == ^feed.id and st.trip_id == ^trip.id and st.stop_id == ^stop.id and st.stop_sequence == ^2
        )
      )

    assert %StopTime{
             shape_dist_traveled: 0.3616,
             arrival_time: %Interval{hours: 22, minutes: 10, seconds: 57},
             departure_time: %Interval{hours: 22, minutes: 10, seconds: 57}
           } = stop_time
  end

  describe "departure calculation" do
    test "it calculates agency timezone stop times correctly", %{gtfs_file: gtfs_file} do
      {:ok, start_time} = Timex.parse("2015-06-06 22:01:00-04:00", "{ISO:Extended}")
      {:ok, end_time} = Timex.parse("2015-06-06 23:01:00-04:00", "{ISO:Extended}")

      Importer.import_from_file(
        "TEST",
        gtfs_file,
        start_date: Timex.to_date(Timex.shift(start_time, days: -1)),
        end_date: Timex.to_date(Timex.shift(end_time, days: 1))
      )

      [feed] = Repo.all(from(feed in Feed))
      stop = Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINw"))
      trip = Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))

      stop_time =
        Repo.one(
          from(
            st in StopTime,
            where:
              st.feed_id == ^feed.id and st.trip_id == ^trip.id and st.stop_id == ^stop.id and st.stop_sequence == ^2
          )
        )

      result = GTFS.projected_stop_times_for_stop(stop, start_time, end_time)

      assert 1 == Enum.count(result)
      assert stop_time.id == Enum.at(result, 0).stop_time_id
    end

    test "it calculates utc stop times correctly", %{gtfs_file: gtfs_file} do
      {:ok, start_time} = Timex.parse("2015-06-07 02:01:00-0000", "{ISO:Extended}")
      {:ok, end_time} = Timex.parse("2015-06-07 03:01:00-0000", "{ISO:Extended}")

      Importer.import_from_file(
        "TEST",
        gtfs_file,
        start_date: Timex.to_date(Timex.shift(start_time, days: -1)),
        end_date: Timex.to_date(Timex.shift(end_time, days: 1))
      )

      [feed] = Repo.all(from(feed in Feed))
      stop = Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINw"))
      trip = Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))

      stop_time =
        Repo.one(
          from(
            st in StopTime,
            where:
              st.feed_id == ^feed.id and st.trip_id == ^trip.id and st.stop_id == ^stop.id and st.stop_sequence == ^2
          )
        )

      result = GTFS.projected_stop_times_for_stop(stop, start_time, end_time)

      assert 1 == Enum.count(result)
      assert stop_time.id == Enum.at(result, 0).stop_time_id
    end

    test "it handles service exceptions correctly", %{gtfs_file: gtfs_file} do
      {:ok, start_time} = Timex.parse("2015-05-26 02:01:00-0000", "{ISO:Extended}")
      {:ok, end_time} = Timex.parse("2015-05-26 03:01:00-0000", "{ISO:Extended}")

      Importer.import_from_file(
        "TEST",
        gtfs_file,
        start_date: Timex.to_date(Timex.shift(start_time, days: -1)),
        end_date: Timex.to_date(Timex.shift(end_time, days: 1))
      )

      [feed] = Repo.all(from(feed in Feed))
      stop = Repo.one(from(s in Stop, where: s.feed_id == ^feed.id and s.remote_id == ^"EZZLINw"))
      trip = Repo.one(from(t in Trip, where: t.feed_id == ^feed.id and t.remote_id == ^"955305"))

      stop_time =
        Repo.one(
          from(
            st in StopTime,
            where:
              st.feed_id == ^feed.id and st.trip_id == ^trip.id and st.stop_id == ^stop.id and st.stop_sequence == ^2
          )
        )

      result = GTFS.projected_stop_times_for_stop(stop, start_time, end_time)

      assert 1 == Enum.count(result)
      assert stop_time.id == Enum.at(result, 0).stop_time_id
    end
  end
end
