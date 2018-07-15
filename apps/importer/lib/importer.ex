defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS import logic.
  """

  require Logger

  import Ecto.Query

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Interval, Route, Service, Shape, Stop, StopTime, Trip}
  alias BusDetective.Repo
  alias Ecto.Type
  alias Importer.{ColorFunctions, StringFunctions}
  alias Timex.Timezone
  alias Timex.Interval, as: TimexInterval

  def import_from_url(url) do
    {:ok, tmp_file} = download_gtfs_file(url)
    import_from_file(tmp_file)
  end

  def import_from_file(file) do
    with {:ok, tmp_path} <- Briefly.create(directory: true),
         {:ok, file_map} <- unzip_gtfs_file(file, tmp_path) do
      [agency] = import_agencies(file_map["agency"])

      services_map = import_services(file_map["calendar"], agency)
      import_service_exceptions(file_map["calendar_dates"], agency, services_map)
      routes_map = import_routes(file_map["routes"], agency)
      stops_map = import_stops(file_map["stops"], agency)
      shapes_map = import_shapes(file_map["shapes"], agency)
      trips_map = import_trips(file_map["trips"], agency, routes_map, services_map, shapes_map)
      import_stop_times(file_map["stop_times"], agency, stops_map, trips_map)
      GTFS.update_route_stops()
      project_stop_times(agency)
    else
      error -> error
    end
  end

  def download_gtfs_file(url) do
    {:ok, tmp_file} = Briefly.create()
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    File.write!(tmp_file, body)
    {:ok, tmp_file}
  end

  def unzip_gtfs_file(gtfs_file, tmp_path) do
    case :zip.unzip(String.to_charlist(gtfs_file), [{:cwd, String.to_charlist(tmp_path)}]) do
      {:ok, files} ->
        file_map =
          Enum.reduce(files, %{}, fn file, acc ->
            full_path = List.to_string(file)

            file_data_type =
              full_path
              |> Path.split()
              |> List.last()
              |> String.split(".")
              |> List.first()

            Map.put(acc, file_data_type, full_path)
          end)

        {:ok, file_map}

      error ->
        error
    end
  end

  def import_agencies(file) do
    Logger.info("Importing agencies")

    file
    |> File.stream!()
    |> CSV.decode(headers: true, strip_fields: true)
    |> Enum.map(fn {:ok, raw_agency} ->
      remote_id = raw_agency["agency_id"]

      GTFS.destroy_agency(remote_id)

      agency = %{
        fare_url: raw_agency["agency_fare_url"],
        remote_id: remote_id,
        language: raw_agency["agency_lang"],
        name: raw_agency["agency_name"],
        phone: raw_agency["agency_phone"],
        timezone: raw_agency["agency_timezone"],
        url: raw_agency["agency_url"]
      }

      {:ok, agency = %Agency{}} = GTFS.create_agency(agency)
      agency
    end)
  end

  def import_services(file, %Agency{id: agency_id}) do
    Logger.info("Importing services")

    {_services_count, services} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.map(fn {:ok, raw_service} ->
        start_date = raw_service["start_date"] |> Timex.parse!("%Y%m%d", :strftime) |> Timex.to_date()
        end_date = raw_service["end_date"] |> Timex.parse!("%Y%m%d", :strftime) |> Timex.to_date()
        {:ok, monday} = maybe_cast(:boolean, raw_service["monday"])
        {:ok, tuesday} = maybe_cast(:boolean, raw_service["tuesday"])
        {:ok, wednesday} = maybe_cast(:boolean, raw_service["wednesday"])
        {:ok, thursday} = maybe_cast(:boolean, raw_service["thursday"])
        {:ok, friday} = maybe_cast(:boolean, raw_service["friday"])
        {:ok, saturday} = maybe_cast(:boolean, raw_service["saturday"])
        {:ok, sunday} = maybe_cast(:boolean, raw_service["sunday"])

        %{
          agency_id: agency_id,
          remote_id: raw_service["service_id"],
          monday: monday,
          tuesday: tuesday,
          wednesday: wednesday,
          thursday: thursday,
          friday: friday,
          saturday: saturday,
          sunday: sunday,
          start_date: start_date,
          end_date: end_date,
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> GTFS.bulk_create_services()

    Enum.reduce(services, %{}, fn %Service{id: id, remote_id: remote_id, agency_id: agency_id}, acc ->
      Map.put(acc, {agency_id, remote_id}, id)
    end)
  end

  def import_service_exceptions(file, %Agency{id: agency_id}, services_map) do
    Logger.info("Importing service exceptions")

    file
    |> File.stream!()
    |> CSV.decode(headers: true, strip_fields: true)
    |> Enum.map(fn {:ok, raw_service_exception} ->
      service_id = services_map[{agency_id, raw_service_exception["service_id"]}]
      date = raw_service_exception["date"] |> Timex.parse!("%Y%m%d", :strftime) |> Timex.to_date()
      {:ok, exception} = maybe_cast(:integer, raw_service_exception["exception_type"])

      %{
        agency_id: agency_id,
        service_id: service_id,
        date: date,
        exception: exception,
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc()
      }
    end)
    |> GTFS.bulk_create_service_exceptions()
  end

  def import_routes(file, %Agency{id: agency_id}) do
    Logger.info("Importing routes")

    {_routes_count, routes} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.map(fn {:ok, raw_route} ->
        %{
          agency_id: agency_id,
          remote_id: raw_route["route_id"],
          short_name: raw_route["route_short_name"],
          long_name: raw_route["route_long_name"],
          description: StringFunctions.titleize(raw_route["route_desc"]),
          route_type: raw_route["route_type"],
          url: raw_route["route_url"],
          color: raw_route["route_color"],
          text_color: ColorFunctions.text_color_for_bg_color(raw_route["route_text_color"]),
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> GTFS.bulk_create_routes()

    Enum.reduce(routes, %{}, fn %Route{id: id, remote_id: remote_id, agency_id: agency_id}, acc ->
      Map.put(acc, {agency_id, remote_id}, id)
    end)
  end

  def maybe_cast(type, value) do
    case value do
      nil -> {:ok, nil}
      "" -> {:ok, nil}
      value -> Type.cast(type, value)
    end
  end

  def import_stops(file, %Agency{id: agency_id}) do
    Logger.info("Importing stops")

    {_stops_count, stops} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.map(fn {:ok, raw_stop} ->
        {:ok, code} = maybe_cast(:integer, raw_stop["stop_code"])
        {:ok, latitude} = maybe_cast(:float, raw_stop["stop_lat"])
        {:ok, longitude} = maybe_cast(:float, raw_stop["stop_lon"])
        {:ok, location_type} = maybe_cast(:integer, raw_stop["location_type"])
        {:ok, wheelchair_boarding} = maybe_cast(:integer, raw_stop["wheelchair_boarding"])
        {:ok, zone_id} = maybe_cast(:integer, raw_stop["zone_id"])

        %{
          agency_id: agency_id,
          remote_id: raw_stop["stop_id"],
          code: code,
          name: StringFunctions.titleize(raw_stop["stop_name"]),
          description: StringFunctions.titleize(raw_stop["stop_desc"]),
          latitude: latitude,
          longitude: longitude,
          zone_id: zone_id,
          url: raw_stop["stop_url"],
          location_type: location_type,
          parent_station: raw_stop["parent_station"],
          timezone: raw_stop["stop_timezone"],
          wheelchair_boarding: wheelchair_boarding,
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> Enum.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, stops} = GTFS.bulk_create_stops(batch)
        {count + added, inserted ++ stops}
      end)

    Enum.reduce(stops, %{}, fn %Stop{id: id, remote_id: remote_id, agency_id: agency_id}, acc ->
      Map.put(acc, {agency_id, remote_id}, id)
    end)
  end

  def import_shapes(file, %Agency{id: agency_id}) do
    Logger.info("Importing shapes")

    {_shapes_count, shapes} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.reduce(%{}, fn {:ok, shape}, acc ->
        {_, new_acc} =
          Map.get_and_update(acc, shape["shape_id"], fn current_value ->
            {current_value, [shape | current_value || []]}
          end)

        new_acc
      end)
      |> Enum.map(fn {shape_id, shapes} ->
        coordinates =
          shapes
          |> Enum.sort_by(fn shape -> String.to_integer(shape["shape_pt_sequence"]) end)
          |> Enum.map(fn point -> {point["shape_pt_lat"], point["shape_pt_lon"]} end)

        %{
          agency_id: agency_id,
          geometry: %Geo.LineString{srid: 4326, coordinates: coordinates},
          remote_id: shape_id,
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> Enum.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, shapes} = GTFS.bulk_create_shapes(batch)
        {count + added, inserted ++ shapes}
      end)

    Enum.reduce(shapes, %{}, fn %Shape{id: id, remote_id: remote_id, agency_id: agency_id}, acc ->
      Map.put(acc, {agency_id, remote_id}, id)
    end)
  end

  def import_trips(file, %Agency{id: agency_id}, routes_map, services_map, shapes_map) do
    Logger.info("Importing trips")

    {_trip_count, trips} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.map(fn {:ok, raw_trip} ->
        route_id = routes_map[{agency_id, raw_trip["route_id"]}]
        service_id = services_map[{agency_id, raw_trip["service_id"]}]
        shape_id = shapes_map[{agency_id, raw_trip["shape_id"]}]

        %{
          agency_id: agency_id,
          route_id: route_id,
          service_id: service_id,
          shape_id: shape_id,
          remote_id: raw_trip["trip_id"],
          headsign: StringFunctions.titleize_headsign(raw_trip["trip_headsign"]),
          short_name: raw_trip["trip_short_name"],
          direction_id: raw_trip["direction_id"] |> String.to_integer(),
          block_id: raw_trip["block_id"] |> String.to_integer(),
          wheelchair_accessible: raw_trip["wheelchair_accessible"] |> String.to_integer(),
          bikes_allowed: raw_trip["bikes_allowed"] |> String.to_integer(),
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> GTFS.bulk_create_trips()

    Enum.reduce(trips, %{}, fn %Trip{id: id, agency_id: agency_id, remote_id: remote_id}, acc ->
      Map.put(acc, {agency_id, remote_id}, id)
    end)
  end

  def import_stop_times(file, %Agency{id: agency_id}, stops_map, trips_map) do
    Logger.info("Importing stop times")

    file
    |> File.stream!()
    |> CSV.decode(headers: true, strip_fields: true)
    |> Enum.map(fn {:ok, raw_stop_time} ->
      stop_id = stops_map[{agency_id, raw_stop_time["stop_id"]}]
      trip_id = trips_map[{agency_id, raw_stop_time["trip_id"]}]

      {:ok, arrival_time} = maybe_cast(Interval, raw_stop_time["arrival_time"])
      {:ok, departure_time} = maybe_cast(Interval, raw_stop_time["departure_time"])
      {:ok, shape_dist_traveled} = maybe_cast(:float, raw_stop_time["shape_dist_traveled"])
      {:ok, stop_sequence} = maybe_cast(:integer, raw_stop_time["stop_sequence"])

      %{
        agency_id: agency_id,
        stop_id: stop_id,
        trip_id: trip_id,
        stop_sequence: stop_sequence,
        shape_dist_traveled: shape_dist_traveled,
        arrival_time: arrival_time,
        departure_time: departure_time,
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc()
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
      {added, stop_times} = GTFS.bulk_create_stop_times(batch)
      {count + added, inserted ++ stop_times}
    end)
  end

  def project_stop_times(%Agency{id: agency_id, timezone: tz}) do
    Logger.info("Projecting stop times")
    timezone = Timezone.get(tz)

    services =
      Repo.all(
        from(
          service in Service,
          where: service.agency_id == ^agency_id
        )
      )

    start_date =
      services
      |> Enum.map(& &1.start_date)
      |> Enum.min_by(&Date.to_erl/1)

    end_date =
      services
      |> Enum.map(& &1.end_date)
      |> Enum.max_by(&Date.to_erl/1)

    service_dates = map_service_dates(services, %TimexInterval{from: start_date, until: end_date})

    Enum.each(service_dates, fn {service, dates} ->
      service
      |> load_stop_times()
      |> Stream.flat_map(fn stop_time ->
        Enum.map(dates, fn date ->
          %{
            stop_time_id: stop_time.id,
            scheduled_arrival_time: shift_stop_time(date, timezone, stop_time.arrival_time),
            scheduled_departure_time: shift_stop_time(date, timezone, stop_time.departure_time),
            inserted_at: Timex.now(),
            updated_at: Timex.now()
          }
        end)
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, projected_stop_time_ids} = GTFS.bulk_create_projected_stop_times(batch)
        {count + added, inserted ++ projected_stop_time_ids}
      end)
    end)
  end

  defp map_service_dates(services, interval) do
    Enum.reduce(
      interval,
      %{},
      fn date, acc ->
        Enum.reduce(active_services(services, date), acc, fn service, acc ->
          dates = Map.get(acc, service, [])
          Map.put(acc, service, [date | dates])
        end)
      end
    )
  end

  def shift_stop_time(date, timezone, interval) do
    offset = interval |> Map.take([:hours, :minutes, :seconds]) |> Map.to_list()

    date
    |> start_of_agency_day(timezone)
    |> Timex.shift(offset)
    |> Timezone.convert(:utc)
  end

  defp load_stop_times(service) do
    Repo.all(
      from(
        stop_time in StopTime,
        join: trip in assoc(stop_time, :trip),
        where: trip.service_id == ^service.id
      ),
      timeout: 60_000
    )
  end

  defp active_services(services, date) do
    weekday_name = date |> Timex.format!("{WDfull}")
    Enum.filter(services, fn service -> Service.weekday_schedule(service)[weekday_name] end)
  end

  def start_of_agency_day(date, agency_timezone) do
    case NaiveDateTime.new(date, ~T[12:00:00]) do
      {:ok, naive_noon} ->
        noon = Timex.to_datetime(naive_noon, agency_timezone)
        Timex.shift(noon, hours: -12)

      error ->
        error
    end
  end
end
