defmodule BusDetectiveWeb.SearchControllerTest do
  use BusDetectiveWeb.ConnCase

  import BusDetectiveWeb.Router.Helpers, only: [search_path: 3]

  describe "search" do
    test "when searching by query param it returns results", %{conn: conn} do
      stop = insert(:stop)

      conn = get(conn, search_path(conn, :index, search_query: stop.name))

      assert html_response(conn, 200)
      refute is_nil(conn.assigns[:results])
    end

    test "when searching by location it returns results", %{conn: conn} do
      insert(:stop)

      conn = get(conn, search_path(conn, :index, latitude: "1", longitude: "1"))

      assert html_response(conn, 200)
      refute is_nil(conn.assigns[:results])
    end

    test "when searching without params it returns an error", %{conn: conn} do
      insert(:stop)

      conn = get(conn, search_path(conn, :index, []))

      assert html_response(conn, 422)
    end
  end
end
