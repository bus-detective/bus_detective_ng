defmodule BusDetectiveWeb.HomePageController do
  use BusDetectiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show_everything(conn, _params) do
    shapes =
      Shape
      |> Repo.all()
      |> Enum.map(&Shape.coordinates_to_map/1)

    render(conn, "everything.html", shapes: shapes)
  end
end
