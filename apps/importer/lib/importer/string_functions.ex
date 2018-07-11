defmodule Importer.StringFunctions do
  @moduledoc """
  This module contains string manipulation functions to make the GTFS more human friendly.
  """

  @excluded []

  def titleize(nil), do: nil

  def titleize(string) do
    string
    |> String.split(" ")
    |> Enum.map(fn word ->
      case(Enum.member?(@excluded, word)) do
        true ->
          String.downcase(word)

        false ->
          String.capitalize(word)
      end
    end)
    |> Enum.join(" ")
  end

  def titleize_headsign(nil), do: nil

  def titleize_headsign(string) do
    string
    |> String.replace(~r/^\d+[Xx]? /, "")
    |> titleize()
  end
end
