use Mix.Config

config :logger, level: :info
config :logger, :console, format: "[$level] $message\n"

# kubernetes
config :peerage,
  via: Peerage.Via.List,
  node_list: [:"el_kube@127.0.0.1"],
  log_results: false

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
