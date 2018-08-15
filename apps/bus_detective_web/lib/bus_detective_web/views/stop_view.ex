defmodule BusDetectiveWeb.StopView do
  use BusDetectiveWeb, :view

  alias BusDetective.GTFS.Stop
  alias Geo.Point

  def map_shapes(nil), do: "[]"

  def map_shapes(departures) do
    departures
    |> Enum.map(fn departure ->
      coords =
        departure.trip.shape.geometry.coordinates
        |> Enum.map(fn {lat, lng} -> "[#{lat}, #{lng}]" end)
        |> Enum.join(", ")

      "[" <> coords <> "]"
    end)
    |> Enum.join(", ")
  end

  def latitude(%Stop{location: %Point{coordinates: {_, latitude}}}), do: latitude
  def latitude(_), do: nil

  def longitude(%Stop{location: %Point{coordinates: {longitude, _}}}), do: longitude
  def longitude(_), do: nil
end
