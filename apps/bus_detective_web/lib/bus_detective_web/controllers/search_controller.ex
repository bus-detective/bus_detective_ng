defmodule BusDetectiveWeb.SearchController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS

  def index(conn, %{"search_query" => query} = params) do
    results = GTFS.search_stops(Keyword.merge(paging_params(params), query: query))
    render(conn, "index.html", results: results)
  end

  def index(conn, %{"latitude" => latitude, "longitude" => longitude} = params) do
    results = GTFS.search_stops(Keyword.merge(paging_params(params), latitude: latitude, longitude: longitude))
    render(conn, "index.html", results: results)
  end

  defp paging_params(params) do
    [
      page: params["page"],
      page_size: params["per_page"]
    ]
  end
end
