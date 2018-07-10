defmodule BusDetectiveWeb.DepartureView do
  use BusDetectiveWeb, :view

  alias BusDetectiveWeb.{DepartureView, RouteView, TripView}

  def render("index.json", %{departures: departures}) do
    %{data: %{departures: render_many(departures, DepartureView, "departure.json")}}
  end

  def render("departure.json", %{departure: departure}) do
    %{
      realtime: departure.realtime?,
      time: format_time(departure.time),
      delay: departure.delay,
      scheduled_time: format_time(departure.scheduled_time),
      trip: render_one(departure.trip, TripView, "trip.json"),
      route: render_one(departure.route, RouteView, "route.json")
    }
  end

  defp format_time(naive_datetime) do
    naive_datetime
    |> Timex.to_datetime(:utc)
    |> Timex.format("{ISO:Extended}")
    |> case do
      {:ok, date} -> date
      error -> error
    end
  end
end
