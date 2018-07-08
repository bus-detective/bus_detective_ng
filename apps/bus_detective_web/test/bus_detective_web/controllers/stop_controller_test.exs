defmodule BusDetectiveWeb.StopControllerTest do
  use BusDetectiveWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "index" do

    setup do
      matching_stop = insert(:stop, name: "8th and Walnut")
      _non_matching_stop = insert(:stop, name: "Somewhere else")
      {:ok, matching_stop: matching_stop}
    end

    test "with a query parameter it returns stops with the given street name", %{conn: conn, matching_stop: matching_stop} do
      conn = get conn, stop_path(conn, :index, query: "8th")
      actual_ids = Enum.map(json_response(conn, 200)["data"]["results"], &(&1["id"]))
      assert actual_ids == [matching_stop.id]
    end

    test "with paging parameters it returns correctly paged results", %{conn: conn} do
      for street <- ["Race", "Main", "Oak"] do
        insert(:stop, name: "8th and #{street}")
      end

      conn = get conn, stop_path(conn, :index, query: "8th", per_page: 3, page: 2)

      assert result = json_response(conn, 200)["data"]
      assert 4 == result["total_results"]
      assert 2 == result["total_pages"]
      assert 3 == result["per_page"]
      assert 2 == result["page"]
    end

    test "with invalid parameters it returns a 400", %{conn: conn} do
      conn = get conn, stop_path(conn, :index, foo: "8th")
      assert 400 == conn.status
    end
  end

  # describe "api/stops/:id" do
  #   let!(:stop) { create(:stop, remote_id: "HAMBELi") }

  #   context "with a rails id" do
  #     it "returns the stop" do
  #       get "/api/stops/#{stop.id}"
  #       expect(json["data"]["id"]).to eq(stop.id)
  #     end
  #   end

  #   context "with a legacy remote_id" do
  #     it "returns the stop" do
  #       get "/api/stops/#{stop.remote_id}"
  #       expect(json["data"]["id"]).to eq(stop.id)
  #     end
  #   end
  # end
end
