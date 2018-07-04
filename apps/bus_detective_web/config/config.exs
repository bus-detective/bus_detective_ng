# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bus_detective_web,
  namespace: BusDetectiveWeb,
  ecto_repos: [BusDetective.Repo]

# Configures the endpoint
config :bus_detective_web, BusDetectiveWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/A9jV6ntMelZEi9Pbck8geOVTqCjZTgf3rhCZ/Txrz7TGQzBPL8MXwUgWYOO9Kw5",
  render_errors: [view: BusDetectiveWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BusDetectiveWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :bus_detective_web, :generators,
  context_app: :bus_detective

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
