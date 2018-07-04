defmodule BusDetective.Application do
  @moduledoc """
  The BusDetective Application Service.

  The bus_detective system business domain lives in this application.

  Exposes API to clients such as the `BusDetectiveWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(BusDetective.Repo, [])
      ],
      strategy: :one_for_one,
      name: BusDetective.Supervisor
    )
  end
end
