defmodule Importer.ColorFunctions do
  @moduledoc """
  Module containing color manipulation functions to ease readability of imported data
  """

  @black "000000"
  @white "FFFFFF"

  @suitable_colors [
    "FF8040",
    "FF8000",
    "FF337A",
    "FF48FF",
    "FF7B1A",
    "FF4FFF",
    "FF4AFF",
    "FF2BC5",
    "FF0000",
    "FE4929",
    "FA123A",
    "F94266",
    "F73364",
    "F34180",
    "F48F20",
    "F23C60",
    "F04D69",
    "ED496A",
    "EC7A35",
    "E17600",
    "E19D37",
    "DF20BE",
    "DE9430",
    "DA4925",
    "D82758",
    "D9115C",
    "CA0FA5",
    "B75851",
    "B16934",
    "B800F4",
    "B1E21D",
    "AF5C01",
    "A644A8",
    "808040",
    "808000",
    "88513E",
    "8672E2",
    "008080",
    "008000",
    "5353FF",
    "2998DA",
    "609E0A",
    "80FF80",
    "63F004",
    "63C7DC",
    "9C4E3A",
    "8AD51C",
    "7D67FE",
    "6A7DC1",
    "4EFD02",
    "04B750",
    "2E9276",
    "2E72A9",
    "02A862",
    "0E70E7",
    "00D700",
    "00B700"
  ]
  def suitable_color(color) when is_nil(color) or color == "" do
    Enum.random(@suitable_colors)
  end

  def suitable_color(color), do: color

  def text_color_for_bg_color(background_color, text_color) when is_nil(text_color) or text_color == "" do
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

  def text_color_for_bg_color(_background_color, text_color), do: text_color
end
