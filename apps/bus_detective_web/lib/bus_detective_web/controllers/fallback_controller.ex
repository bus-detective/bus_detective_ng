defmodule BusDetectiveWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BusDetectiveWeb, :controller

  def call(conn, {:error, :invalid_params}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(BusDetectiveWeb.ErrorView, :"500")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(BusDetectiveWeb.ErrorView, :"404")
  end
end
