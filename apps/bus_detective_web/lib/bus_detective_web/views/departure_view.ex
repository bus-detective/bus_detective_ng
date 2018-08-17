defmodule BusDetectiveWeb.DepartureView do
  use BusDetectiveWeb, :view

  alias Timex.Timezone

  def departure_time(time, agency_timezone) do
    time
    |> Timezone.convert(agency_timezone)
    |> Timex.format!("{h12}:{m}{am}")
  end
end
