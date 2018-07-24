defmodule RealtimeTest do
  use ExUnit.Case
  doctest Realtime

  test "greets the world" do
    assert Realtime.hello() == :world
  end
end
