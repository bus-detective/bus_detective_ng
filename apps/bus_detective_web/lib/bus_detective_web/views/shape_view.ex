defmodule BusDetectiveWeb.ShapeView do
  use BusDetectiveWeb, :view

  def render("shape.json", %{shape: shape}) do
    %{
      id: shape.id,
      type: 'LineString',
      coordinates: coordinates(shape)
    }
  end

  def coordinates(shape) do
    Enum.map(shape.geometry.coordinates, fn {x, y} -> [x, y] end)
  end
end
