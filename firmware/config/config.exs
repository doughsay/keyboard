# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :firmware, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :gadget],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

# Configures the endpoint
config :interface, InterfaceWeb.Endpoint,
  http: [port: 80, ip: {0, 0, 0, 0}],
  url: [host: "keyboard.local", port: 80],
  secret_key_base: "pOgEiGJWEsxiX3BmzCNGjiyVUDYG6HGnhzb9FBlG6EeGDiGm1x4tg0TBDqBWA432",
  render_errors: [view: InterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Interface.PubSub, adapter: Phoenix.PubSub.PG2],
  root: Path.dirname(__DIR__),
  server: true

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

if Mix.target() != :host do
  import_config "target.exs"
end
