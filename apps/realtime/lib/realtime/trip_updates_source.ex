defmodule Realtime.TripUpdatesSource do
  @moduledoc """
  This module defines the behavior that a source providing trip updates must implement
  """

  alias Realtime.StopTimeUpdate

  @callback find_stop_time(String.t(), String.t(), non_neg_integer()) ::
              {:ok, StopTimeUpdate.t()} | {:error, :no_realtime_proces}
end
