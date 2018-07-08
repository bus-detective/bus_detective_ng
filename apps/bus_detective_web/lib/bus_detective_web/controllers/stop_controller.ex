defmodule BusDetectiveWeb.StopController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS
  alias BusDetectiveWeb.ErrorView

  action_fallback(BusDetectiveWeb.FallbackController)

  def index(conn, %{"query" => query} = params) do
    results = GTFS.search_stops(Keyword.merge(paging_params(params), query: query))
    render(conn, "index.json", results: results)
  end

  def index(conn, _) do
    conn
    |> put_status(:bad_request)
    |> render(ErrorView, "400.json")
  end

  # def show(conn, %{"id" => id}) do
  #   stop = GTFS.get_stop!(id)
  #   render(conn, "show.json", stop: stop)
  # end

  defp paging_params(params) do
    [
      page: params["page"],
      page_size: params["per_page"]
    ]
  end
end
