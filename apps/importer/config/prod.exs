use Mix.Config

config :importer,
  schedules: %{
    System.get_env("FEED_NAME") => %{
      gtfs_schedule_url: System.get_env("FEED_SCHEDULE_URL")
    }
  }
