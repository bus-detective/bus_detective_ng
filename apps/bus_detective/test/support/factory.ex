defmodule BusDetective.Factory do
  use ExMachina.Ecto, repo: BusDetective.Repo

  alias BusDetective.GTFS.{Agency, Route, Service, ServiceException, Shape, Stop}

  def agency_factory do
    %Agency{
      name: sequence(:agency_name, &"Agency-#{&1}"),
      url: sequence(:agency_url, &"http://url-#{&1}.test"),
      timezone: "America/Detroit"
    }
  end

  def service_factory do
    date = Timex.to_date(Timex.now())

    %Service{
      agency: build(:agency),
      remote_id: sequence(:service_remote_id, &"Service-#{&1}"),
      monday: Enum.random([true, false]),
      tuesday: Enum.random([true, false]),
      wednesday: Enum.random([true, false]),
      thursday: Enum.random([true, false]),
      friday: Enum.random([true, false]),
      saturday: Enum.random([true, false]),
      sunday: Enum.random([true, false]),
      start_date: Timex.shift(date, days: -30),
      end_date: Timex.shift(date, days: 30)
    }
  end

  def service_exception_factory do
    date = Timex.to_date(Timex.now())

    %ServiceException{
      agency: build(:agency),
      service: build(:service),
      date: date,
      exception: Enum.random(0..10)
    }
  end

  def route_factory do
    %Route{
      agency: build(:agency),
      remote_id: sequence(:route_remote_id, &"R#{&1}"),
      short_name: sequence(:route_short_name, &"#{&1}"),
      long_name: sequence(:route_long_name, &"Route #{&1}"),
      route_type: Enum.random(0..7) |> Integer.to_string()
    }
  end

  def stop_factory do
    %Stop{
      agency: build(:agency),
      remote_id: sequence(:stop_remote_id, &"STOP#{&1}"),
      name: sequence(:stop_remote_id, &"5th and Walnut & #{&1} North St"),
      latitude: Float.round(39 + :rand.uniform(), 6),
      longitude: Float.round(-84 - :rand.uniform(), 6)
    }
  end

  def shape_factory do
    %Shape{
      agency: build(:agency),
      remote_id: sequence(:shape_remote_id, &"#{&1}"),
      geometry: %Geo.LineString{
        srid: 4326,
        coordinates: [
          {39.109414, -84.536507},
          {39.109431, -84.536437}
        ]
      }
    }
  end
end
