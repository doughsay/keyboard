use Mix.Config

config :excalibur, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :shoehorn,
  init: [:nerves_runtime, :gadget],
  app: Mix.Project.config()[:app]

config :phoenix, :json_library, Jason

config :excalibur, Excalibur.Interface.Endpoint,
  render_errors: [view: Excalibur.Interface.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Excalibur.PubSub, adapter: Phoenix.PubSub.PG2]

import_config "#{Mix.target()}/config.exs"
