defmodule BusDetective.GTFS.Interval do
  @moduledoc """
  This implements Interval support for Postgrex that used to be in Ecto but no longer is.
  """

  defstruct [:hours, :minutes, :seconds]

  @behaviour Ecto.Type
  def type, do: Postgrex.Interval

  def cast(value) when is_binary(value) do
    [hours, minutes, seconds] =
      value
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    {:ok, %__MODULE__{hours: hours, minutes: minutes, seconds: seconds}}
  end

  def cast(%__MODULE__{} = interval) do
    {:ok, interval}
  end

  def dump(%__MODULE__{hours: hours, minutes: minutes, seconds: seconds}) do
    total_seconds = (hours || 0) * 3600 + (minutes || 0) * 60 + seconds
    {:ok, %Postgrex.Interval{secs: total_seconds}}
  end

  def load(%Postgrex.Interval{days: days, secs: seconds}) do
    total_seconds = days * 86400 + seconds
    hours = trunc(total_seconds / 3600)
    minutes = trunc(rem(total_seconds, 3600) / 60)
    seconds = rem(rem(total_seconds, 3600), 60)
    {:ok, %__MODULE__{hours: hours, minutes: minutes, seconds: seconds}}
  end
end

defimpl Inspect, for: [BusDetective.GTFS.Interval] do
  def inspect(inv, _opts) do
    inspect(Map.from_struct(inv))
  end
end
