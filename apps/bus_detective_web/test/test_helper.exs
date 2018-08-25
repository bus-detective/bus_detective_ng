ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(BusDetective.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, BusDetectiveWeb.Endpoint.url())

Mox.defmock(BusDetectiveWeb.VehiclePositionsMock, for: Realtime.VehiclePositionsSource)
