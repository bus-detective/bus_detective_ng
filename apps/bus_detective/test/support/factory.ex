defmodule BusDetective.Factory do
  use ExMachina.Ecto, repo: BusDetective.Repo

  alias BusDetective.GTFS.{
    Agency,
    Interval,
    ProjectedStopTime,
    Route,
    RouteStop,
    Service,
    ServiceException,
    Shape,
    Stop,
    StopTime,
    Trip
  }

  def agency_factory do
    %Agency{
      remote_id: sequence(:agency_remote_id, &"Agency Remote ID #{&1}"),
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
      start_date: Timex.shift(Timex.now(), days: -30),
      end_date: Timex.shift(Timex.now(), days: 30)
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

  def route_stop_factory do
    %RouteStop{
      route: build(:route),
      stop: build(:stop)
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
      agency: agency,
      stop: build(:stop, agency: agency),
      trip: build(:trip, agency: agency),
      stop_sequence: stop_time_sequence,
      shape_dist_traveled: stop_time_sequence * 0.5,
      arrival_time: %Interval{seconds: 56_000 + stop_time_sequence * 2},
      departure_time: %Interval{seconds: 56_000 + stop_time_sequence * 2 + 1}
    }
  end

  def projected_stop_time_factory do
    %ProjectedStopTime{
      stop_time: build(:stop_time),
      scheduled_arrival_time: Timex.now(),
      scheduled_departure_time: Timex.now()
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

  def with_agency(%Route{} = route, agency) do
    %{route | agency: agency}
  end

  def with_agency(%Service{} = service, agency) do
    %{service | agency: agency}
  end

  def with_agency(%ServiceException{} = service_exception, agency) do
    %{service_exception | agency: agency, service: with_agency(service_exception.service, agency)}
  end

  def with_agency(%Shape{} = shape, agency) do
    %{shape | agency: agency}
  end

  def with_agency(%Stop{} = stop, agency) do
    %{stop | agency: agency}
  end

  def with_agency(%StopTime{} = stop_time, agency) do
    %{stop_time | agency: agency, stop: with_agency(stop_time.stop, agency), trip: with_agency(stop_time.trip, agency)}
  end

  def with_agency(%Trip{} = trip, agency) do
    %{
      trip
      | agency: agency,
        route: with_agency(trip.route, agency),
        service: with_agency(trip.service, agency),
        shape: with_agency(trip.shape, agency)
    }
  end
end
