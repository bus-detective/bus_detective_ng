defmodule BusDetectiveWeb.UserSocket do
  use Phoenix.Socket

  channel "favorites:*", BusDetectiveWeb.FavoritesChannel

  transport(:websocket, Phoenix.Transports.WebSocket, timeout: 45_000)
  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
