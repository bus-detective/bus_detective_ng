defmodule Realtime.Messages do
  @moduledoc """
  Entrypoint module for GTFS Realtime protobuf generated structs
  """

  use Protobuf, from: Path.expand(Path.join(File.cwd!(), "proto/gtfs-realtime.proto"))
end
