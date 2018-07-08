defmodule BusDetective.Factory do
  use ExMachina.Ecto, repo: BusDetective.Repo

  alias BusDetective.GTFS.{Agency, Route, Service, ServiceException, Shape, Stop, StopTime, Trip}

  def agency_factory do
    %Agency{
      name: sequence(:agency_name, &"Agency-#{&1}"),
      url: sequence(:agency_url, &"http://url-#{&1}.test"),
      timezone: "America/Detroit"
    }
  end

  def service_factory do
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
      start_date: Timex.parse!("2000-01-01 00:00:00-0000", "{ISO:Extended}"),
      end_date: Timex.parse!("3000-01-01 00:00:00-0000", "{ISO:Extended}")
    }
  end

  def service_exception_factory do
    date = Timex.to_date(Timex.now())
    agency = build(:agency)

    %ServiceException{
      agency: agency,
      service: build(:service, agency: agency),
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

  def stop_time_factory do
    stop_time_sequence = sequence(:stop_time_sequence, & &1)
    agency = build(:agency)

    %StopTime{
      agency: build(:agency),
      stop: build(:stop, agency: agency),
      trip: build(:trip, agency: agency),
      stop_sequence: stop_time_sequence,
      shape_dist_traveled: stop_time_sequence * 0.5,
      arrival_time: 56_000 + stop_time_sequence * 2,
      departure_time: 56_000 + stop_time_sequence * 2 + 1
    }
  end

  def trip_factory do
    agency = build(:agency)

    %Trip{
      agency: agency,
      remote_id: sequence(:trip_remote_id, &"Trip#{&1}"),
      route: build(:route, agency: agency),
      service: build(:service, agency: agency),
      shape: build(:shape, agency: agency),
      block_id: sequence(:trip_block_id, & &1)
    }
  end
end
