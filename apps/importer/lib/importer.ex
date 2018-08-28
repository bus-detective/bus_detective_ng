defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS scheduled data import logic.
  """

  require Logger

  alias BusDetective.GTFS.{Agency, Feed, Interval, Route, Service, Shape, Stop, Trip}
  alias Ecto.Type
  alias Importer.{ColorFunctions, GTFSImport, ProjectedStopTimeImporter, StringFunctions}

  @doc """
  Imports a GTFS schedule feed from the given file
  """
  def import_from_file(name, file, opts \\ []) do
    with file_hash <- file_hash(file) do
      feed =
        case GTFSImport.get_feed_by_name(name) do
          nil ->
            {:ok, feed} = GTFSImport.create_feed(%{name: name})
            feed

          %Feed{} = feed ->
            feed
        end

      import_feed(feed, file_hash, file, opts)
    end
  end

  @doc """
  Imports a GTFS schedule feed from the given url
  """
  def import_from_url(name, url, opts \\ []) do
    {:ok, tmp_file} = download_gtfs_file(url)
    import_from_file(name, tmp_file, opts)
  end

  defp delete_data(feed) do
    Logger.info(fn -> "Start deleting transient and calculated data for #{feed.name}" end)
    Logger.debug(fn -> "Deleting service exceptions for #{feed.name}" end)
    GTFSImport.destroy_service_exceptions_for_feed(feed)
    Logger.debug(fn -> "Deleting stop times for #{feed.name}" end)
    GTFSImport.destroy_stop_times_for_feed(feed)
    Logger.debug(fn -> "Deleting route stops for #{feed.name}" end)
    GTFSImport.destroy_route_stops_for_feed(feed)
    Logger.info(fn -> "Done deleting transient and calculated data for #{feed.name}" end)
  end

  defp download_gtfs_file(url) do
    {:ok, tmp_file} = Briefly.create()
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    File.write!(tmp_file, body)
    {:ok, tmp_file}
  end

  defp file_hash(file) do
    file
    |> File.stream!([], 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn line, acc -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final()
    |> Base.encode16()
  end

  defp import_agencies(file, %Feed{id: feed_id}) do
    Logger.info("Importing agencies")

    file
    |> File.stream!()
    |> CSV.decode(headers: true, strip_fields: true)
    |> Enum.map(fn {:ok, raw_agency} ->
      remote_id = raw_agency["agency_id"]

      changeset = %{
        feed_id: feed_id,
        remote_id: remote_id,
        fare_url: raw_agency["agency_fare_url"],
        language: raw_agency["agency_lang"],
        name: raw_agency["agency_name"],
        phone: raw_agency["agency_phone"],
        timezone: raw_agency["agency_timezone"],
        url: raw_agency["agency_url"]
      }

      {:ok, agency} =
        case GTFSImport.get_agency_by_remote_id(feed_id, remote_id) do
          nil ->
            GTFSImport.create_agency(changeset)

          %Agency{} = agency ->
            GTFSImport.update_agency(agency, changeset)
        end

      agency
    end)
    |> Enum.reduce(%{}, fn agency, acc -> Map.put(acc, agency.remote_id, agency.id) end)
  end

  defp import_feed(%Feed{last_file_hash: file_hash} = feed, file_hash, _, opts) do
    Logger.info(fn -> "Skipping full import for #{feed.name}, file hash unchanged" end)
    ProjectedStopTimeImporter.project_stop_times(feed, opts)
    {:ok, :partial_update}
  end

  defp import_feed(%Feed{} = feed, file_hash, file, opts) do
    with {:ok, tmp_path} <- Briefly.create(directory: true),
         {:ok, file_map} <- unzip_gtfs_file(file, tmp_path) do
      delete_data(feed)

      agencies = import_agencies(file_map["agency"], feed)
      feed = GTFSImport.preload_agencies(feed)
      services_task = Task.async(fn -> import_services(file_map["calendar"], feed) end)
      routes_task = Task.async(fn -> import_routes(file_map["routes"], feed, agencies) end)
      stops_task = Task.async(fn -> import_stops(file_map["stops"], feed) end)
      shapes_task = Task.async(fn -> import_shapes(file_map["shapes"], feed) end)
      services = Task.await(services_task, 300_000)
      import_service_exceptions(file_map["calendar_dates"], feed, services)
      routes = Task.await(routes_task, 300_000)
      shapes = Task.await(shapes_task, 300_000)
      trips = import_trips(file_map["trips"], feed, routes, services, shapes)
      stops = Task.await(stops_task, 300_000)
      import_stop_times(file_map["stop_times"], feed, stops, trips)
      GTFSImport.update_route_stops(feed)
      ProjectedStopTimeImporter.project_stop_times(feed, opts)

      {:ok, _} = GTFSImport.update_feed(feed, %{last_file_hash: file_hash, last_updated: Timex.now()})
      {:ok, :full_update}
    else
      error -> error
    end
  end

  defp import_routes(file, %Feed{id: feed_id}, agencies) do
    Logger.info("Importing routes")

    {routes_count, routes} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.map(fn {:ok, raw_route} ->
        agency_id = agencies[raw_route["agency_id"]] || Enum.at(agencies, 0)
        route_color = ColorFunctions.suitable_color(raw_route["route_color"])

        %{
          feed_id: feed_id,
          agency_id: agency_id,
          remote_id: raw_route["route_id"],
          short_name: raw_route["route_short_name"],
          long_name: raw_route["route_long_name"],
          description: StringFunctions.titleize(raw_route["route_desc"]),
          route_type: raw_route["route_type"],
          url: raw_route["route_url"],
          color: route_color,
          text_color: ColorFunctions.text_color_for_bg_color(route_color, raw_route["route_text_color"]),
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> GTFSImport.bulk_create_routes()

    Logger.info("Done importing #{routes_count} routes")

    Enum.reduce(routes, %{}, fn %Route{id: id, remote_id: remote_id}, acc ->
      Map.put(acc, remote_id, id)
    end)
  end

  defp import_service_exceptions(file, %Feed{id: feed_id}, services) do
    Logger.info("Importing service exceptions")

    service_exceptions =
      {service_exceptions_count, _} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Enum.map(fn {:ok, raw_service_exception} ->
        service_id = services[raw_service_exception["service_id"]]
        date = raw_service_exception["date"] |> Timex.parse!("%Y%m%d", :strftime) |> Timex.to_date()
        {:ok, exception} = maybe_cast(:integer, raw_service_exception["exception_type"])

        %{
          feed_id: feed_id,
          service_id: service_id,
          date: date,
          exception: exception,
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> GTFSImport.bulk_create_service_exceptions()

    Logger.info("Done importing #{service_exceptions_count} service exceptions")

    service_exceptions
  end

  defp import_services(file, %Feed{id: feed_id}) do
    Logger.info("Importing services")

    {services_count, services} =
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
          feed_id: feed_id,
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
      |> GTFSImport.bulk_create_services()

    Logger.info("Done importing #{services_count} services")

    Enum.reduce(services, %{}, fn %Service{id: id, remote_id: remote_id}, acc ->
      Map.put(acc, remote_id, id)
    end)
  end

  defp import_shapes(file, %Feed{id: feed_id}) do
    Logger.info("Importing shapes")

    {shapes_count, shapes} =
      file
      |> File.stream!()
      |> CSV.decode!(headers: true, strip_fields: true)
      |> Stream.chunk_by(fn %{"shape_id" => shape_id} -> shape_id end)
      |> Stream.map(fn shapes ->
        shape_id = Enum.at(shapes, 0)["shape_id"]

        coordinates =
          shapes
          |> Enum.sort_by(fn shape -> String.to_integer(shape["shape_pt_sequence"]) end)
          |> Enum.map(fn point -> {point["shape_pt_lon"], point["shape_pt_lat"]} end)

        %{
          feed_id: feed_id,
          geometry: %Geo.LineString{srid: 4326, coordinates: coordinates},
          remote_id: shape_id,
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, shapes} = GTFSImport.bulk_create_shapes(batch)
        {count + added, inserted ++ shapes}
      end)

    Logger.info("Done importing #{shapes_count} shapes")

    Enum.reduce(shapes, %{}, fn %Shape{id: id, remote_id: remote_id}, acc ->
      Map.put(acc, remote_id, id)
    end)
  end

  defp import_stop_times(file, %Feed{id: feed_id}, stops, trips) do
    Logger.info("Importing stop times")

    stop_times =
      {stop_times_count, _} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Stream.map(fn {:ok, raw_stop_time} ->
        stop_id = stops[raw_stop_time["stop_id"]]
        trip_id = trips[raw_stop_time["trip_id"]]

        {:ok, arrival_time} = maybe_cast(Interval, raw_stop_time["arrival_time"])
        {:ok, departure_time} = maybe_cast(Interval, raw_stop_time["departure_time"])
        {:ok, shape_dist_traveled} = maybe_cast(:float, raw_stop_time["shape_dist_traveled"])
        {:ok, stop_sequence} = maybe_cast(:integer, raw_stop_time["stop_sequence"])

        %{
          feed_id: feed_id,
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
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, stop_times} = GTFSImport.bulk_create_stop_times(batch)
        {count + added, inserted ++ stop_times}
      end)

    Logger.info("Done importing #{stop_times_count} stop times")

    stop_times
  end

  defp import_stops(file, %Feed{id: feed_id}) do
    Logger.info("Importing stops")

    {stops_count, stops} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Stream.map(fn {:ok, raw_stop} ->
        {:ok, code} = maybe_cast(:integer, raw_stop["stop_code"])
        {:ok, latitude} = maybe_cast(:float, raw_stop["stop_lat"])
        {:ok, longitude} = maybe_cast(:float, raw_stop["stop_lon"])

        location =
          case is_nil(latitude) or is_nil(longitude) do
            true -> nil
            false -> %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}
          end

        {:ok, location_type} = maybe_cast(:integer, raw_stop["location_type"])
        {:ok, wheelchair_boarding} = maybe_cast(:integer, raw_stop["wheelchair_boarding"])
        {:ok, zone_id} = maybe_cast(:integer, raw_stop["zone_id"])

        %{
          feed_id: feed_id,
          remote_id: raw_stop["stop_id"],
          code: code,
          name: StringFunctions.titleize(raw_stop["stop_name"]),
          description: StringFunctions.titleize(raw_stop["stop_desc"]),
          location: location,
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
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, stops} = GTFSImport.bulk_create_stops(batch)
        {count + added, inserted ++ stops}
      end)

    Logger.info("Done importing #{stops_count} stops")

    Enum.reduce(stops, %{}, fn %Stop{id: id, remote_id: remote_id}, acc ->
      Map.put(acc, remote_id, id)
    end)
  end

  defp import_trips(file, %Feed{id: feed_id}, routes, services, shapes) do
    Logger.info("Importing trips")

    {trips_count, trips} =
      file
      |> File.stream!()
      |> CSV.decode(headers: true, strip_fields: true)
      |> Stream.map(fn {:ok, raw_trip} ->
        route_id = routes[raw_trip["route_id"]]
        service_id = services[raw_trip["service_id"]]
        shape_id = shapes[raw_trip["shape_id"]]

        %{
          feed_id: feed_id,
          route_id: route_id,
          service_id: service_id,
          shape_id: shape_id,
          remote_id: raw_trip["trip_id"],
          headsign: StringFunctions.titleize_headsign(raw_trip["trip_headsign"]),
          short_name: raw_trip["trip_short_name"],
          direction_id: to_integer(raw_trip["direction_id"]),
          block_id: raw_trip["block_id"],
          wheelchair_accessible: to_integer(raw_trip["wheelchair_accessible"]),
          bikes_allowed: to_integer(raw_trip["bikes_allowed"]),
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, []}, fn batch, {count, inserted} ->
        {added, trips} = GTFSImport.bulk_create_trips(batch)
        {count + added, inserted ++ trips}
      end)

    Logger.info("Done importing #{trips_count} trips")

    Enum.reduce(trips, %{}, fn %Trip{id: id, remote_id: remote_id}, acc ->
      Map.put(acc, remote_id, id)
    end)
  end

  defp maybe_cast(type, value) do
    case value do
      nil -> {:ok, nil}
      "" -> {:ok, nil}
      value -> Type.cast(type, value)
    end
  end

  defp to_integer(nil), do: nil

  defp to_integer(value) do
    case Integer.parse(value) do
      {val, ""} ->
        val
      _ -> nil
    end
  end

  defp unzip_gtfs_file(gtfs_file, tmp_path) do
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
end
