defmodule Importer.ColorFunctionsTest do
  use ExUnit.Case

  alias Importer.ColorFunctions

  describe "text_color_for_bg_color/1" do
    test "it uses white on top of black" do
      assert "FFFFFF" == ColorFunctions.text_color_for_bg_color("000000", nil)
    end

    test "it uses white on top of green" do
      assert "FFFFFF" == ColorFunctions.text_color_for_bg_color("008000", nil)
    end

    test "it uses black on top of white" do
      assert "000000" == ColorFunctions.text_color_for_bg_color("FFFFFF", nil)
    end

    test "it uses black on top of yellow" do
      assert "000000" == ColorFunctions.text_color_for_bg_color("FFDD00", nil)
    end

    test "it uses the given color when one is passed" do
      assert "AABBCC" == ColorFunctions.text_color_for_bg_color("FFFFFF", "AABBCC")
    end
  end
end
