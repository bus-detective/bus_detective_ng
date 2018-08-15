defmodule BusDetectiveWeb.SearchPage do
  @moduledoc """
  Module to interact with the busdetective search results page
  """

  use Wallaby.DSL

  import Wallaby.Query, only: [css: 2]

  def search_results(count: count) do
    css("bd-stop", count: count)
  end
end
