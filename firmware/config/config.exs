use Mix.Config

config :firmware, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :shoehorn,
  init: [:nerves_runtime, :gadget],
  app: Mix.Project.config()[:app]

config :phoenix, :json_library, Jason

config :interface, InterfaceWeb.Endpoint,
  render_errors: [view: InterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Interface.PubSub, adapter: Phoenix.PubSub.PG2]

case Mix.target() do
  :host ->
    import_config "host/config.exs"

  target ->
    import_config "target/config.exs"
    import_config "#{target}/config.exs"
end
