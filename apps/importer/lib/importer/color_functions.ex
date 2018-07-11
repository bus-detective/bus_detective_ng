defmodule Importer.ColorFunctions do
  @moduledoc """
  Module containing color manipulation functions to ease readability of imported data
  """

  @black "000000"
  @white "FFFFFF"

  def text_color_for_bg_color(nil), do: @black

  def text_color_for_bg_color(background_color) do
    case Base.decode16(background_color, case: :mixed) do
      {:ok, <<red::integer, green::integer, blue::integer>>} ->
        # This gives a luminosity value from 0 - 255
        case 0.299 * red + 0.587 * green + 0.114 * blue > 170 do
          true -> @black
          false -> @white
        end

      _error ->
        @black
    end
  end
end
