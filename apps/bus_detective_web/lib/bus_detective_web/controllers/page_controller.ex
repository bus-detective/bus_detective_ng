defmodule BusDetectiveWeb.PageController do
  use BusDetectiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
