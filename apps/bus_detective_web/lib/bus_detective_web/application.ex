defmodule BusDetectiveWeb.Application do
  @moduledoc false
  use Application

  alias BusDetectiveWeb.{Endpoint, RealtimeBroker}

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BusDetectiveWeb.Endpoint, []),
      {RealtimeBroker, name: RealtimeBroker}
    ]

    opts = [strategy: :one_for_one, name: BusDetectiveWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
