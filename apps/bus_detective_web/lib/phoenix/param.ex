alias BusDetective.GTFS.Stop

defimpl Phoenix.Param, for: Stop do
  def to_param(%Stop{feed_id: feed_id, remote_id: remote_id}) do
    "#{feed_id}-#{remote_id}"
  end
end
