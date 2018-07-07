defmodule BusDetectiveWeb.AgencyView do
  use BusDetectiveWeb, :view

  def render("agency.json", %{agency: agency}) do
    %{
      id: agency.id,
      remote_id: agency.remote_id,
      name: agency.name,
      url: agency.url,
      fare_url: agency.fare_url,
      phone: agency.phone,
      timezone: agency.timezone
    }
  end
end
