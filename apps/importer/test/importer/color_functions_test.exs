defmodule Importer.ColorFunctionsTest do
  use ExUnit.Case

  alias Importer.ColorFunctions

  describe "text_color_for_bg_color/1" do
    test "it uses white on top of black" do
      assert "FFFFFF" == ColorFunctions.text_color_for_bg_color("000000")
    end

    test "it uses white on top of green" do
      assert "FFFFFF" == ColorFunctions.text_color_for_bg_color("008000")
    end

    test "it uses black on top of white" do
      assert "000000" == ColorFunctions.text_color_for_bg_color("FFFFFF")
    end

    test "it uses black on top of yellow" do
      assert "000000" == ColorFunctions.text_color_for_bg_color("FFDD00")
    end

    test "it uses black for a nil color" do
      assert "000000" == ColorFunctions.text_color_for_bg_color(nil)
    end
  end
end
