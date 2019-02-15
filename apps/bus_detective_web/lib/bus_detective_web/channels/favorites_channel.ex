defmodule BusDetectiveWeb.FavoritesChannel do
  @moduledoc """
  Channel to manage favorite stops
  """
  use Phoenix.Channel

  alias BusDetective.GTFS
  alias BusDetective.GTFS.Stop
  alias Phoenix.Param

  def join("favorites:stops", _message, socket) do
    {:ok, socket}
  end

  def handle_in("load_stops", %{"stop_ids" => stop_ids}, socket) do
    stops =
      stop_ids
      |> GTFS.get_stops()
      |> Enum.map(fn stop ->
        routes =
          Enum.map(stop.routes, fn route ->
            %{
              short_name: route.short_name,
              color: route.color,
              text_color: route.text_color
            }
          end)

        %{
          id: Param.to_param(stop),
          name: stop.name,
          direction: Stop.direction(stop),
          routes: routes
        }
      end)

    push(socket, "favorites_list", %{stops: stops})
    {:noreply, socket}
  end
end
