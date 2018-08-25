defmodule Realtime.VehiclePosition do
  @moduledoc """
  This is a flattened struct to represent the relevant fields from the nested GTFS VehiclePosition protobuf data
  """

  @typedoc """
  * `latitude` - the latitude of the bus location
  * `longitude` - the longitude of the bus location
  * `trip_id` - the string id of the trip defined in the feed (corresponds to remote_id in the Trip schema)
  * `vehicle_label` - the vehicle label given in the realtime vehicle position feed
  """
  @type t :: %__MODULE__{
          latitude: float(),
          longitude: float(),
          trip_id: String.t(),
          vehicle_label: String.t()
        }

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
