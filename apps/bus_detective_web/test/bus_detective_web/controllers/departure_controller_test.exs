defmodule BusDetectiveWeb.DepartureControllerTest do
  use BusDetectiveWeb.ConnCase

  alias Timex.Timezone

  setup %{conn: conn} do
    agency = insert(:agency)

    trip =
      insert(
        :trip,
        agency: agency,
        remote_id: "940135",
        service: insert(:service, agency: agency, tuesday: true, wednesday: true)
      )

    stop = insert(:stop, agency: agency, remote_id: "HAMBELi")

    {
      :ok,
      conn: put_req_header(conn, "accept", "application/json"), agency: agency, trip: trip, stop: stop
    }
  end

  describe "index" do
    test "lists all departures for a given stop and time duration in hours", %{
      conn: conn,
      agency: agency,
      stop: stop,
      trip: trip
    } do
      timezone = Timezone.get(agency.timezone)

      {:ok, departure_time} =
        Timex.now()
        |> Timezone.convert(timezone)
        |> Timex.format("%H:%M:%S", :strftime)

      insert(
        :stop_time,
        agency: agency,
        stop: stop,
        trip: trip,
        arrival_time: departure_time,
        departure_time: departure_time
      )

      conn = get(conn, departure_path(conn, :index, stop_id: stop.id, duration: 1))
      assert response = json_response(conn, 200)["data"]
      assert 1 == length(response["departures"])
    end
  end
end
