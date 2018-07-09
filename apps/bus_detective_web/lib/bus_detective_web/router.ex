defmodule BusDetectiveWeb.Router do
  use BusDetectiveWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BusDetectiveWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api", BusDetectiveWeb do
    pipe_through(:api)

    resources("/departures", DepartureController, only: [:index])
    resources("/stops", StopController, only: [:index, :show])
  end
end
