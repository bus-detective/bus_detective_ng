defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS import logic.
  """

  require Logger

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Interval, Route, Service, Shape, Stop, Trip}
  alias Ecto.Type

  def import(gtfs_file) do
    with {:ok, tmp_path} <- Briefly.create(directory: true),
         {:ok, file_map} <- unzip_gtfs_file(gtfs_file, tmp_path) do
      [agency] = import_agencies(file_map["agency"])
      services_map = import_services(file_map["calendar"], agency)
      import_service_exceptions(file_map["calendar_dates"], agency, services_map)
      routes_map = import_routes(file_map["routes"], agency)
      stops_map = import_stops(file_map["stops"], agency)
      shapes_map = import_shapes(file_map["shapes"], agency)
      trips_map = import_trips(file_map["trips"], agency, routes_map, services_map, shapes_map)
      import_stop_times(file_map["stop_times"], agency, stops_map, trips_map)
      GTFS.update_route_stops()
    else
      error -> error
    end
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
      agency = %{
        fare_url: raw_agency["agency_fare_url"],
        remote_id: raw_agency["agency_id"],
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
          description: raw_route["route_desc"],
          route_type: raw_route["route_type"],
          url: raw_route["route_url"],
          color: raw_route["route_color"],
          text_color: raw_route["route_text_color"],
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
          name: raw_stop["stop_name"],
          description: raw_stop["stop_desc"],
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
          headsign: raw_trip["trip_headsign"],
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
end
