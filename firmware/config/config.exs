use Mix.Config

config :firmware, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :shoehorn,
  init: [:nerves_runtime, :gadget],
  app: Mix.Project.config()[:app]

config :phoenix, :json_library, Jason

config :firmware, InterfaceWeb.Endpoint,
  render_errors: [view: InterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Interface.PubSub, adapter: Phoenix.PubSub.PG2]

import_config "#{Mix.target()}/config.exs"
