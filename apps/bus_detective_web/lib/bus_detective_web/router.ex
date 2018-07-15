defmodule BusDetectiveWeb.Router do
  use BusDetectiveWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", BusDetectiveWeb do
    pipe_through(:browser)

    get("/", HomePageController, :index)

    resources("/search", SearchController, only: [:index])
    resources("/stops", StopController, only: [:show])
  end
end
