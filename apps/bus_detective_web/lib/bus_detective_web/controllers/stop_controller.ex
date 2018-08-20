defmodule BusDetectiveWeb.StopController do
  use BusDetectiveWeb, :controller

  alias BusDetective.GTFS

  action_fallback(BusDetectiveWeb.FallbackController)

  def show(conn, params) do
    case parse_params(params) do
      {:ok, stop_id_params, options} ->
        load_stop(conn, stop_id_params, options)

      error ->
        error
    end
  end

  defp load_stop(conn, [stop_id], _options) do
    with {:ok, stop} <- GTFS.get_stop(stop_id) do
      redirect(conn, to: stop_path(conn, :show, stop))
    else
      {_, str} when is_binary(str) ->
        {:error, :not_found}

      error ->
        error
    end
  end

  defp load_stop(conn, [feed_id, stop_remote_id], options) do
    with {:ok, stop} <- GTFS.get_stop(feed_id, stop_remote_id),
         {:ok, duration} <- Keyword.fetch(options, :duration),
         start_time <- Timex.shift(Timex.now(), minutes: -10),
         end_time <- Timex.shift(Timex.now(), hours: duration) do
      departures = GTFS.departures_for_stop(stop, start_time, end_time)
      render(conn, "show.html", stop: stop, departures: departures)
    end
  end

  defguardp is_id(split_params) when is_list(split_params) and length(split_params) > 0 and length(split_params) < 3

  defp parse_params(%{"id" => stop_id_str} = params) do
    with id_params when is_id(id_params) <- String.split(stop_id_str, "-"),
         {_, ""} <- Integer.parse(hd(id_params)),
         {duration, ""} <- Integer.parse(Map.get(params, "duration", "1")) do
      {:ok, id_params, duration: duration}
    else
      _ ->
        {:error, :invalid_params}
    end
  end
end
