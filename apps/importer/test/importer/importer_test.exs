defmodule Importer.ImporterTest do
  use BusDetective.DataCase

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Agency

  setup do
    gtfs_file = Path.join(File.cwd!(), "test/fixtures/google_transit_info.zip") |> IO.inspect()
    {:ok, gtfs_file: gtfs_file}
  end

  test "it imports the agency", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)

    agency = GTFS.list_agencies() |> List.first

    assert %Agency{
      fare_url: "http://www.go-metro.com/fares-passes",
      remote_id: "SORTA",
      language: "en",
      name: "Southwest Ohio Regional Transit Authority",
      phone: "513-621-4455",
      timezone: "America/Detroit",
      url: "http://www.go-metro.com"
    } = agency
  end
end
