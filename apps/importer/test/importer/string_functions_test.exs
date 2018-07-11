defmodule Importer.StringFunctionsTest do
  use ExUnit.Case

  alias Importer.StringFunctions

  describe "titleize/1" do
    test "with nil it returns nil" do
      assert is_nil(StringFunctions.titleize(nil))
    end

    test "with a normal caps string it returns the input" do
      input = "Montgomery Rd & Lester Rd"
      assert input == StringFunctions.titleize(input)
    end

    test "with an all caps string it titleizes the string" do
      input = "MONTGOMERY RD & LESTER RD"
      assert "Montgomery Rd & Lester Rd" == StringFunctions.titleize(input)
    end
  end

  describe "titleize_headsign" do
    test "with nil it returns nil" do
      assert is_nil(StringFunctions.titleize_headsign(nil))
    end

    test "with a normal string it returns the string" do
      input = "Montgomery Express - Downtown"
      assert input == StringFunctions.titleize_headsign(input)
    end

    test "with a string that begins with a route number it removes the number and titleizes the remainder" do
      input = "33 WESTERN HILLS GLENWAY - DOWNTOWN"
      assert "Western Hills Glenway - Downtown" == StringFunctions.titleize_headsign(input)
    end

    test "with a string that begins with an express route number it removes the express number and titleizes the rest" do
      input = "4X MONTGOMERY EXPRESS - DOWNTOWN"
      assert "Montgomery Express - Downtown" == StringFunctions.titleize_headsign(input)
    end
  end
end
