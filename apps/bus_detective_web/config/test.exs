use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bus_detective_web, BusDetectiveWeb.Endpoint,
  http: [port: 4001],
  server: true

config :bus_detective, :sql_sandbox, true

config :wallaby,
  driver: Wallaby.Experimental.Chrome,
  screenshot_on_failure: true
