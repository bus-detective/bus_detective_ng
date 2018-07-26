defmodule Importer.Application do
  @moduledoc """
  The Importer Application Service.

  The GTFS importer application logic lives here.
  """
  use Application

  alias Importer.ScheduledImporter

  def start(_type, _args) do
    children =
      schedule_feeds()
      |> Enum.map(fn {feed_name, %{gtfs_schedule_url: gtfs_schedule_url}} ->
        ScheduledImporter.child_spec(feed_name: feed_name, gtfs_schedule_url: gtfs_schedule_url, id: feed_name)
      end)

    opts = [strategy: :one_for_one, name: Importer.Supervisor]
    Supervisor.start_link([{Registry, keys: :unique, name: ScheduledImporter} | children], opts)
  end

  defp schedule_feeds do
    Application.get_env(:importer, :schedules)
  end
end
