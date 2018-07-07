defmodule BusDetectiveWeb.RouteView do
  use BusDetectiveWeb, :view
  alias BusDetectiveWeb.RouteView

  def render("index.json", %{routes: routes}) do
    %{routes: render_many(routes, RouteView, "route.json")}
  end

  def render("route.json", %{route: route}) do
    %{
      id: route.id,
      short_name: route.short_name,
      long_name: route.long_name,
      color: route.color,
      text_color: route.text_color
    }
  end
end
