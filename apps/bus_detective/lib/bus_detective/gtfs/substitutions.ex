defmodule BusDetective.GTFS.Substitutions do
  @moduledoc """
  This module assists with building substitutions for text search (eg ordinals
  and abbreviations).
  """

  alias Cldr.Number

  @word_substitutions [
    ["alley", "aly"],
    ["avenue", "ave"],
    ["boulevard", "blvd"],
    ["court", "ct"],
    ["circle", "cir"],
    ["expressway", "expy", "exp"],
    ["freeway", "fwy"],
    ["highway", "hwy"],
    ["lane", "ln"],
    ["place", "pl"],
    ["parkway", "pkwy"],
    ["road", "rd"],
    ["route", "rte"],
    ["square", "sq", "sqr"],
    ["street", "st", "str"]
  ]

  def build_substitutions do
    @word_substitutions
    |> Enum.concat(number_substitutions())
    |> Enum.reduce(%{}, fn like_terms, acc ->
      Enum.reduce(like_terms, acc, fn term, acc ->
        Map.put(acc, term, like_terms)
      end)
    end)
  end

  def number_substitutions do
    for number <- 1..999 do
      [
        Number.to_string!(number),
        Number.to_string!(number, format: :ordinal),
        Number.to_string!(number, format: :spellout_ordinal),
        Number.to_string!(number, format: :spellout)
      ]
    end
  end
end
