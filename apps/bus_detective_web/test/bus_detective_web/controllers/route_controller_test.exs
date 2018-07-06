defmodule BusDetectiveWeb.RouteControllerTest do
  use BusDetectiveWeb.ConnCase

  setup %{conn: conn} do
    other_agency = insert(:agency)
    insert_list(4, :route, agency: other_agency)

    agency = insert(:agency)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), agency: agency}
  end

  describe "index" do
    test "lists all routes for an agency", %{conn: conn, agency: agency} do
      insert_list(5, :route, agency: agency)
      conn = get(conn, route_path(conn, :index, agency_id: agency.id))
      assert 5 == length(json_response(conn, 200)["routes"])
    end
  end
end
