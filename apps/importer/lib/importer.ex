defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS import logic.
  """

  alias BusDetective.GTFS
  alias BusDetective.GTFS.{Agency, Service}

  def import(gtfs_file) do
    with {:ok, tmp_path} <- Briefly.create(directory: true),
         {:ok, file_map} <- unzip_gtfs_file(gtfs_file, tmp_path) do
      [agency] = import_agencies(file_map["agency"])
      import_services(file_map["calendar"], agency: agency)
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
    |> Enum.each(fn {:ok, raw_service} ->
      start_date = Timex.parse!(raw_service["start_date"], "%Y%m%d", :strftime) |> Timex.to_date()
      end_date = Timex.parse!(raw_service["end_date"], "%Y%m%d", :strftime) |> Timex.to_date()

      service = %{
        agency_id: agency_id,
        remote_id: raw_service["service_id"],
        monday: raw_service["monday"],
        tuesday: raw_service["tuesday"],
        wednesday: raw_service["wednesday"],
        thursday: raw_service["thursday"],
        friday: raw_service["friday"],
        saturday: raw_service["saturday"],
        sunday: raw_service["sunday"],
        start_date: start_date,
        end_date: end_date
      }

      {:ok, %Service{}} = GTFS.create_service(service)
    end)
  end
end
