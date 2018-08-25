defmodule Realtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Realtime.{TripUpdates, VehiclePositions}

  def start(_type, _args) do
    children =
      [
        {Registry, keys: :unique, name: TripUpdates},
        {Registry, keys: :unique, name: VehiclePositions},
        {Registry, keys: :duplicate, name: Registry.Realtime, id: Registry.Realtime}
      ] ++ trip_updates_children() ++ vehicle_positions_children()

    opts = [strategy: :one_for_one, name: Realtime.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp realtime_feeds do
    Application.get_env(:realtime, :feeds)
  end

  defp trip_updates_children() do
    case Application.get_env(:realtime, TripUpdates)[:enabled] do
      true ->
        realtime_feeds()
        |> Enum.map(fn {feed_name, %{trip_updates_url: trip_updates_url}} ->
          TripUpdates.child_spec(
            feed_name: feed_name,
            trip_updates_url: trip_updates_url,
            id: "#{feed_name}-TripUpdates"
          )
        end)

      _ ->
        []
    end
  end

  defp vehicle_positions_children() do
    case Application.get_env(:realtime, VehiclePositions)[:enabled] do
      true ->
        realtime_feeds()
        |> Enum.map(fn {feed_name, %{vehicle_positions_url: vehicle_positions_url}} ->
          VehiclePositions.child_spec(
            feed_name: feed_name,
            vehicle_positions_url: vehicle_positions_url,
            id: "#{feed_name}-VehiclePositions"
          )
        end)

      _ ->
        []
    end
  end
end
