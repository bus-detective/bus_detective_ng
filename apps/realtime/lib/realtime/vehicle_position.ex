defmodule Realtime.VehiclePosition do
  @moduledoc """
  This is a flattened struct to represent the relevant fields from the nested GTFS VehiclePosition protobuf data
  """

  defstruct [:trip_id, :latitude, :longitude, :vehicle_label]

  def from_message(%Realtime.Messages.FeedEntity{vehicle: nil}), do: nil

  def from_message(%Realtime.Messages.FeedEntity{vehicle: vehicle_position}) do
    %__MODULE__{
      trip_id: vehicle_position.trip.trip_id,
      latitude: vehicle_position.position.latitude,
      longitude: vehicle_position.position.longitude,
      vehicle_label: vehicle_position.vehicle.label
    }
  end

  def from_message(_), do: nil
end
