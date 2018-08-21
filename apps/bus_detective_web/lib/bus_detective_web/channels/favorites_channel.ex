defmodule BusDetectiveWeb.FavoritesChannel do
  @moduledoc """
  Channel to manage favorite stops
  """
  use Phoenix.Channel

  alias BusDetective.GTFS
  alias BusDetectiveWeb.StopView
  alias Phoenix.View

  def join("favorites:stops", _message, socket) do
    {:ok, socket}
  end

  def handle_in("load_stops", %{"stop_ids" => stop_ids}, socket) do
    stops =
      stop_ids
      |> GTFS.get_stops()
      |> Enum.map(fn stop ->
        View.render_to_string(
          StopView,
          "_stop.html",
          stop: stop
        )
      end)

    push(socket, "favorites_list", %{stops: stops})
    {:noreply, socket}
  end
end
