defmodule Importer.ImporterTest do
  use ExUnit.Case

  setup do
    gtfs_file = Path.join(File.cwd!, "test/fixtures/google_transit_info.zip") |> IO.inspect
    {:ok, gtfs_file: gtfs_file}
  end

  test "it imports the agency", %{gtfs_file: gtfs_file} do
    Importer.import(gtfs_file)
    |> IO.inspect
  end
end
