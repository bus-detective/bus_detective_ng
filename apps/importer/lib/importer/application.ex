defmodule Importer.Application do
  @moduledoc """
  The Importer Application Service.

  The GTFS importer application logic lives here.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([], strategy: :one_for_one, name: Importer.Supervisor)
  end
end
