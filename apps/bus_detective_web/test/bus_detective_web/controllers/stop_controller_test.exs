defmodule BusDetectiveWeb.StopControllerTest do
  use BusDetectiveWeb.ConnCase

  import BusDetectiveWeb.Router.Helpers, only: [stop_path: 3]

  describe "show" do
    test "when passed an id it redirects to the feed/remote_id url", %{conn: conn} do
      stop = insert(:stop)

      conn = get(conn, "/stops/#{stop.id}")

      assert redirected_to(conn) =~ stop_path(conn, :show, stop)
    end

    test "when passed an id that doesn't exist it returns a 404", %{conn: conn} do
      conn = get(conn, stop_path(conn, :show, "45"))

      assert response(conn, 404)
    end

    test "when passed an feed/remote_id it returns a 200", %{conn: conn} do
      stop = insert(:stop)

      conn = get(conn, stop_path(conn, :show, stop))

      assert response(conn, 200)
    end

    test "when passed a feed/remote_id that doesn't exist it returns a 404", %{conn: conn} do
      conn = get(conn, stop_path(conn, :show, "45-ERRBADe"))

      assert response(conn, 404)
    end

    test "when passed bad params it returns a 422", %{conn: conn} do
      conn = get(conn, stop_path(conn, :show, "lkjhasdf"))

      assert response(conn, 422)
    end
  end
end
