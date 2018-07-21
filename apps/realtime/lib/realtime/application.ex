defmodule Realtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Realtime.TripUpdates

  def start(_type, _args) do
    children =
      realtime_feeds()
      |> Enum.map(fn {agency_remote_id, %{trip_updates_url: trip_updates_url}} ->
        TripUpdates.child_spec(agency: agency_remote_id, trip_updates_url: trip_updates_url, id: agency_remote_id)
      end)

    opts = [strategy: :one_for_one, name: Realtime.Supervisor]
    Supervisor.start_link([{Registry, keys: :unique, name: TripUpdates} | children], opts)
  end

  defp realtime_feeds do
    Application.get_env(:realtime, :feeds)
  end
end
