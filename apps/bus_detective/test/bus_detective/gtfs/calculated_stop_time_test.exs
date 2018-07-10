defmodule BusDetective.CalculatedStopTimeTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  # alias BusDetective.GTFS.StopTime
  alias Timex.Timezone

  setup do
    agency = insert(:agency)

    trip =
      insert(
        :trip,
        agency: agency,
        remote_id: "940135",
        service: insert(:service, agency: agency, tuesday: true, wednesday: true)
      )

    stop = insert(:stop, agency: agency, remote_id: "HAMBELi")

    {:ok, agency: agency, stop: stop, trip: trip}
  end

  describe "with stops on different days" do
    setup %{agency: agency, stop: stop, trip: trip} do
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "22:00:00")
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "23:00:00")
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "00:30:00")
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "01:00:00")

      :ok
    end

    test "when requesting stops on the same day it finds those stops", %{stop: stop} do
      start_time = Timex.parse!("2015-05-12 22:00:00-0400", "{ISO:Extended}")
      end_time = Timex.parse!("2015-05-12 23:30:00-0400", "{ISO:Extended}")

      stop_times = GTFS.calculated_stop_times_between(stop, start_time, end_time)
      assert 2 == length(stop_times)
      assert Timezone.convert(start_time, :utc) == Timex.to_datetime(List.first(stop_times).calculated_departure_time)
    end

    test "with stops that cross the local time day boundary it finds those stops", %{stop: stop} do
      start_time = Timex.parse!("2015-05-12 23:00:00-0400", "{ISO:Extended}")
      end_time = Timex.parse!("2015-05-13 01:30:00-0400", "{ISO:Extended}")

      stop_times = GTFS.calculated_stop_times_between(stop, start_time, end_time)
      assert 3 == length(stop_times)
    end
  end

  describe "with stops on the same day" do
    setup %{agency: agency, stop: stop, trip: trip} do
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "22:00:00")
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "23:00:00")
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "24:30:00")
      insert(:stop_time, agency: agency, stop: stop, trip: trip, departure_time: "25:00:00")

      :ok
    end

    test "having stops on the same day it finds those stops", %{stop: stop} do
      start_time = Timex.parse!("2015-05-12 22:00:00-0400", "{ISO:Extended}")
      end_time = Timex.parse!("2015-05-12 23:30:00-0400", "{ISO:Extended}")

      stop_times = GTFS.calculated_stop_times_between(stop, start_time, end_time)
      assert 2 == length(stop_times)
    end

    test "with stops that cross the local time day boundary it finds those stops", %{stop: stop} do
      start_time = Timex.parse!("2015-05-12 23:00:00-0400", "{ISO:Extended}")
      end_time = Timex.parse!("2015-05-13 01:30:00-0400", "{ISO:Extended}")

      stop_times = GTFS.calculated_stop_times_between(stop, start_time, end_time)
      assert 3 == length(stop_times)
    end
  end
end
