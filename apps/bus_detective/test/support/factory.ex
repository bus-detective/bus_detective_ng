defmodule BusDetective.Factory do
  use ExMachina.Ecto, repo: BusDetective.Repo

  alias BusDetective.GTFS.{Agency, Service}

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
end
