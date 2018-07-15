defmodule BusDetectiveWeb.StopView do
  use BusDetectiveWeb, :view

  alias Timex.Timezone

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

  def departure_time(time, agency_timezone) do
    time
    |> Timezone.convert(agency_timezone)
    |> Timex.format!("{h12}:{m}{am}")
  end
end
