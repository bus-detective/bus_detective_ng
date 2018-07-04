defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS import logic.
  """

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Agency

  def import(gtfs_file) do
    with {:ok, tmp_path} <- Briefly.create(directory: true),
         {:ok, file_map} <- unzip_gtfs_file(gtfs_file, tmp_path) do
      import_agencies(file_map["agency"])
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
    |> Enum.each(fn {:ok, raw_agency} ->
      IO.inspect(raw_agency)

      agency =
        %{
          fare_url: raw_agency["agency_fare_url"],
          remote_id: raw_agency["agency_id"],
          language: raw_agency["agency_lang"],
          name: raw_agency["agency_name"],
          phone: raw_agency["agency_phone"],
          timezone: raw_agency["agency_timezone"],
          url: raw_agency["agency_url"]
        }
        |> IO.inspect()

      {:ok, %Agency{}} = GTFS.create_agency(agency) |> IO.inspect()
    end)
  end
end
