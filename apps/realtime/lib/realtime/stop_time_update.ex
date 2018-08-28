defmodule Realtime.StopTimeUpdate do
  @moduledoc """
  A flattened version of a StopTimeUpdate useful for overlaying on top of scheduled StopTimes
  """

  require Logger

  alias Realtime.Messages.TripUpdate.StopTimeUpdate, as: StopTimeUpdateMessage

  @typedoc """
  * `delay` - The delay of the departure in seconds
  * `departure_time` - The estimated time of departure
  * `stop_id` - the stop id as given by the source (relates to the remote_id of the Stop struct)
  * `stop_sequence` - the sequence number of the stop on the trip
  """
  @type t :: %__MODULE__{
          delay: integer(),
          departure_time: DateTime.t(),
          stop_id: String.t(),
          stop_sequence: non_neg_integer()
        }

  defstruct [:delay, :departure_time, :stop_id, :stop_sequence]

  def from_message(%StopTimeUpdateMessage{} = message) do
    with {:ok, departure_time} <- departure_time([message.arrival, message.departure]),
         delay <- delay([message.arrival, message.departure]) do
      %__MODULE__{
        departure_time: departure_time,
        delay: delay,
        stop_id: message.stop_id,
        stop_sequence: message.stop_sequence
      }
    end
  end

  def from_message(_), do: nil

  defp delay(arrival_and_departure) do
    arrival_and_departure
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.map(& &1.delay)
    |> Enum.max()
  end

  defp departure_time(arrival_and_departure) do
    arrival_and_departure
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.map(& &1.time)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.max()
    |> case do
         nil -> nil
         datetime -> DateTime.from_unix(datetime)
    end
  end
end
