defmodule BusDetectiveWeb.SearchPage do
  @moduledoc """
  Module to interact with the busdetective search results page
  """

  use Wallaby.DSL

  import Wallaby.Query, only: [css: 1, css: 2]

  alias BusDetective.GTFS.Stop

  def favorite_stop(session, %Stop{} = stop) do
    click(session, css("bd-favorite[stop-id='#{Phoenix.Param.to_param(stop)}'] button"))
  end

  def search_results(count: count) do
    css("[data-test='stop_item']", count: count)
  end
end
