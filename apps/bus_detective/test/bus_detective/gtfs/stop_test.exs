defmodule BusDetective.GTFS.StopTest do
  use ExUnit.Case

  alias BusDetective.GTFS.Stop

  describe "direction/1" do
    test "with a direction letter it returns a label" do
      assert "inbound" == Stop.direction(%Stop{remote_id: "PNWEASi"})
    end

    test "with a non-matching letter it returns an empty string" do
      assert "" == Stop.direction(%Stop{remote_id: "PNWEAS"})
    end
  end
end
