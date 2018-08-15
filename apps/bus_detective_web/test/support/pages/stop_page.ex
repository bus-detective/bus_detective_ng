defmodule BusDetectiveWeb.StopPage do
  @moduledoc """
  Module to interact with the busdetective stop page
  """

  use Wallaby.DSL

  import Wallaby.Query, only: [css: 2]
  import BusDetectiveWeb.Router.Helpers, only: [stop_path: 4]

  alias BusDetective.GTFS.Stop
  alias BusDetectiveWeb.Endpoint

  def visit_page(session, %Stop{id: stop_id}, duration \\ 1) do
    visit(session, stop_path(Endpoint, :show, stop_id, duration: duration))
  end

  def departure_results(count: count) do
    css("bd-departure", count: count)
  end
end
