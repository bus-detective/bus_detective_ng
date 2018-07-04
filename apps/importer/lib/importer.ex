defmodule Importer do
  @moduledoc """
  Importer keeps the GTFS import logic.
  """

  def import(url) do
    {:ok, path} = Briefly.create |> IO.inspect
    case :zip.unzip(String.to_charlist(url), [{:cwd, String.to_charlist(path)}]) do
      {:ok, files} ->
        files
        |> Enum.map(&List.to_string(&1))

      error -> error
    end
  end
end
