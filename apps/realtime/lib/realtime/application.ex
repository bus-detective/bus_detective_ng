defmodule Realtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Realtime.{TripUpdates, VehiclePositions}

  def start(_type, _args) do
    children =
      realtime_feeds()
      |> Enum.map(fn {feed_name, %{trip_updates_url: trip_updates_url, vehicle_positions_url: vehicle_positions_url}} ->
        [
          TripUpdates.child_spec(
            feed_name: feed_name,
            trip_updates_url: trip_updates_url,
            id: "#{feed_name}-TripUpdates"
          ),
          VehiclePositions.child_spec(
            feed_name: feed_name,
            vehicle_positions_url: vehicle_positions_url,
            id: "#{feed_name}-VehiclePositions"
          )
        ]
      end)
      |> List.flatten()

    opts = [strategy: :one_for_one, name: Realtime.Supervisor]

    Supervisor.start_link(
      [{Registry, keys: :unique, name: TripUpdates}, {Registry, keys: :unique, name: VehiclePositions}] ++ children,
      opts
    )
  end

  defp realtime_feeds do
    Application.get_env(:realtime, :feeds)
  end
end
