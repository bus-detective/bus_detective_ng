defmodule BusDetectiveWeb.HomePage do
  @moduledoc """
  Module to interact with the busdetective home page
  """

  use Wallaby.DSL

  import Wallaby.Query, only: [css: 1]

  alias BusDetective.GTFS.Stop

  def favorite(%Stop{} = stop) do
    css("[data-test='stop_item'][data-id='#{Phoenix.Param.to_param(stop)}']")
  end

  def visit_page(session) do
    visit(session, "/")
  end

  def search(session, stop_name) do
    session
    |> fill_in(css("[data-test='search_query']"), with: stop_name)
    |> click(css("[data-test='search_button']"))
  end
end
