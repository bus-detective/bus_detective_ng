defmodule BusDetective.GTFS.StopSearch do
  @moduledoc """
  This module provides stop search functionality.
  """

  import Ecto.Query
  import Geo.PostGIS, only: [st_distance: 2]

  @substitutions [
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

  def query_string(query, nil), do: query

  def query_string(query, search_string) do
    join_pg_search(query, build_ts_query(search_string))
  end

  def query_nearby(query, latitude, longitude) do
    case is_nil(latitude) or is_nil(longitude) do
      true ->
        query

      false ->
        location = %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}
        from(s in query, order_by: st_distance(s.location, ^location))
    end
  end

  def join_pg_search(query, ts_query_terms) do
    query
    |> join(
      :inner,
      [stop],
      pg_search in fragment(
        ~s{
        SELECT "stops"."id" AS pg_search_id,
        ts_rank(to_tsvector('english', coalesce("stops"."name"::text, '')) || to_tsvector('english', coalesce("stops"."code"::text, '')), to_tsquery('english', ?)), 0 AS rank
        FROM "stops" WHERE to_tsvector('english', coalesce("stops"."name"::text, '')) || to_tsvector('english', coalesce("stops"."code"::text, '')) @@ to_tsquery('english', ?)
        },
        ^ts_query_terms,
        ^ts_query_terms
      ),
      stop.id == pg_search.pg_search_id
    )
    |> order_by([stop, pg_search], desc: pg_search.rank, asc: stop.id)
  end

  def build_ts_query(search_string) do
    substitutions = build_substitutions()

    search_string
    |> String.downcase()
    |> String.split(~r{&| and })
    |> Enum.map(&"(#{build_ts_term(&1, substitutions)})")
    |> Enum.join(" & ")
  end

  defp build_ts_term(term, substitutions) do
    term
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&expand_substitutions(&1, substitutions))
    |> Enum.join(" & ")
  end

  def build_substitutions do
    Enum.reduce(@substitutions, %{}, fn like_terms, acc ->
      Enum.reduce(like_terms, acc, fn term, acc ->
        Map.put(acc, term, like_terms)
      end)
    end)
  end

  defp expand_substitutions(lexeme, substitutions) do
    case substitutions do
      %{^lexeme => like_terms} ->
        "(" <> Enum.join(like_terms, " | ") <> ")"

      _ ->
        lexeme
    end
  end
end
