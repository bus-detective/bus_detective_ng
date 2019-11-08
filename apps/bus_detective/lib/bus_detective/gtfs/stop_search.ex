defmodule BusDetective.GTFS.StopSearch do
  @moduledoc """
  This module provides stop search functionality.
  """

  import Ecto.Query
  import Geo.PostGIS, only: [st_distance: 2]

  alias BusDetective.GTFS.Substitutions

  @substitutions Substitutions.build_substitutions()

  def query_nearby(query, latitude, longitude) do
    case is_nil(latitude) or is_nil(longitude) do
      true ->
        query

      false ->
        location = %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}
        from(s in query, order_by: st_distance(s.location, ^location))
    end
  end

  def query_string(query, nil), do: query

  def query_string(query, search_string) do
    join_pg_search(query, build_ts_query(search_string))
  end

  defp build_ts_query(search_string) do
    search_string
    |> String.downcase()
    |> String.split(~r{&| and })
    |> Enum.map(&"(#{build_ts_term(&1)})")
    |> Enum.join(" & ")
  end

  defp build_ts_term(term) do
    term
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&expand_substitutions(&1))
    |> Enum.join(" & ")
  end

  defp expand_substitutions(lexeme) do
    case @substitutions do
      %{^lexeme => like_terms} ->
        "('" <> Enum.join(like_terms, "' | '") <> "')"

      _ ->
        lexeme
    end
  end

  defp join_pg_search(query, ts_query_terms) do
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
      on: stop.id == pg_search.pg_search_id
    )
    |> order_by([stop, pg_search], desc: pg_search.rank, asc: stop.id)
  end
end
