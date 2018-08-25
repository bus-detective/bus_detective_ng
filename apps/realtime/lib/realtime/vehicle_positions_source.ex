defmodule Realtime.VehiclePositionsSource do
  @moduledoc """
  This module defines the behavior that a source providing vehicle positions must implement
  """

  alias Realtime.VehiclePosition

  @callback find_vehicle_position(String.t(), String.t()) :: {:ok, VehiclePosition.t()} | {:error, :no_realtime_proces}
end
