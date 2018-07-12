defmodule BusDetectiveWeb.FeatureCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Wallaby.Browser

  using do
    quote do
      use Wallaby.DSL

      alias BusDetective.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import BusDetective.Factory
      import BusDetectiveWeb.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BusDetective.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(BusDetective.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(BusDetective.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    session = Browser.resize_window(session, 1400, 900)
    {:ok, session: session}
  end
end
