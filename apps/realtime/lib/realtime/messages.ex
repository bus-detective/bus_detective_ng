defmodule Realtime.Messages do
  use Protobuf, from: Path.expand(Path.join(File.cwd!, "proto/gtfs-realtime.proto"))
end
