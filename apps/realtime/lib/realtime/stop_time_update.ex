defmodule Realtime.StopTimeUpdate do
  @moduledoc """
  A flattened version of a StopTimeUpdate useful for overlaying on top of scheduled StopTimes
  """

  require Logger

  defstruct [:departure_time, :delay, :stop_id, :stop_sequence]

  alias Realtime.Messages.TripUpdate.StopTimeUpdate, as: StopTimeUpdateMessage

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

  defp departure_time(arrival_and_departure) do
    arrival_and_departure
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.map(& &1.time)
    |> Enum.max()
    |> DateTime.from_unix()
  end

  defp delay(arrival_and_departure) do
    arrival_and_departure
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.map(& &1.delay)
    |> Enum.max()
  end
end
