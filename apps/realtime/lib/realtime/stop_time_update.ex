defmodule Realtime.StopTimeUpdate do
  @moduledoc """
  A flattened version of a StopTimeUpdate useful for overlaying on top of scheduled StopTimes
  """

  defstruct [:departure_time, :delay, :stop_id, :stop_sequence]

  alias Realtime.Messages.TripUpdate.StopTimeUpdate, as: StopTimeUpdateMessage
  alias Realtime.Messages.TripUpdate.StopTimeEvent

  def from_message(%StopTimeUpdateMessage{} = message) do
    with {:ok, departure} <- departure(message.arrival, message.departure),
         {:ok, departure_time} <- departure_time(departure) do
      %__MODULE__{
        departure_time: departure_time,
        delay: departure.delay,
        stop_id: message.stop_id,
        stop_sequence: message.stop_sequence
      }
    end
  end

  def from_message(_), do: nil

  defp departure(_, %StopTimeEvent{} = departure), do: {:ok, departure}

  defp departure(arrival, nil), do: {:ok, arrival}

  defp departure(_, _), do: {:error, :no_departure}

  defp departure_time(nil), do: {:error, :no_departure_time}

  defp departure_time(%StopTimeEvent{} = departure) do
    DateTime.from_unix(departure.time)
  end
end
