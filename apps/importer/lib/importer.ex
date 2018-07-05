defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS import logic.
  """

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Route, Service, ServiceException, Stop}

  def import(gtfs_file) do
    with {:ok, tmp_path} <- Briefly.create(directory: true),
         {:ok, file_map} <- unzip_gtfs_file(gtfs_file, tmp_path) do
      [agency] = import_agencies(file_map["agency"])
      import_services(file_map["calendar"], agency: agency)
      import_service_exceptions(file_map["calendar_dates"], agency: agency)
      import_routes(file_map["routes"], agency: agency)
      import_stops(file_map["stops"], agency: agency)
    else
      error -> error
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

  defp import_agencies(file) do
    file
    |> File.stream!()
    |> CSV.decode(headers: true)
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

  defp import_services(file, agency: %Agency{id: agency_id}) do
    file
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.each(fn {:ok, raw_service_exception} ->
      start_date = Timex.parse!(raw_service_exception["start_date"], "%Y%m%d", :strftime) |> Timex.to_date()
      end_date = Timex.parse!(raw_service_exception["end_date"], "%Y%m%d", :strftime) |> Timex.to_date()

      service = %{
        agency_id: agency_id,
        remote_id: raw_service_exception["service_id"],
        monday: raw_service_exception["monday"],
        tuesday: raw_service_exception["tuesday"],
        wednesday: raw_service_exception["wednesday"],
        thursday: raw_service_exception["thursday"],
        friday: raw_service_exception["friday"],
        saturday: raw_service_exception["saturday"],
        sunday: raw_service_exception["sunday"],
        start_date: start_date,
        end_date: end_date
      }

      {:ok, %Service{}} = GTFS.create_service(service)
    end)
  end

  defp import_service_exceptions(file, agency: agency = %Agency{id: agency_id}) do
    file
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.each(fn {:ok, raw_service_exception} ->
      %Service{id: service_id} = GTFS.get_service(agency: agency, remote_id: raw_service_exception["service_id"])
      date = Timex.parse!(raw_service_exception["date"], "%Y%m%d", :strftime) |> Timex.to_date()

      service_exception = %{
        agency_id: agency_id,
        service_id: service_id,
        date: date,
        exception: raw_service_exception["exception_type"]
      }

      {:ok, %ServiceException{}} = GTFS.create_service_exception(service_exception)
    end)
  end

  def import_routes(file, agency: %Agency{id: agency_id}) do
    file
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.each(fn {:ok, raw_route} ->
      route = %{
      agency_id: agency_id,
      remote_id: raw_route["route_id"],
      short_name: raw_route["route_short_name"],
      long_name: raw_route["route_long_name"],
      route_desc: raw_route["description"],
      route_type: raw_route["route_type"],
      url: raw_route["route_url"],
      color: raw_route["route_color"],
      text_color: raw_route["route_text_color"]
    }

      {:ok, %Route{}} = GTFS.create_route(route)
    end)
  end

  def import_stops(file, agency: %Agency{id: agency_id}) do
    file
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.each(fn {:ok, raw_stop} ->
      stop = %{
        agency_id: agency_id,
        remote_id: raw_stop["stop_id"],
        code: raw_stop["stop_code"],
        name: raw_stop["stop_name"],
        description: raw_stop["stop_desc"],
        latitude: raw_stop["stop_lat"],
        longitude: raw_stop["stop_lon"],
        zone_id: raw_stop["zone_id"],
        url: raw_stop["stop_url"],
        location_type: raw_stop["location_type"],
        parent_station: raw_stop["parent_station"],
        timezone: raw_stop["stop_timezone"],
        wheelchair_boarding: raw_stop["wheelchair_boarding"],
      }

      {:ok, %Stop{}} = GTFS.create_stop(stop)
    end)
  end
end
