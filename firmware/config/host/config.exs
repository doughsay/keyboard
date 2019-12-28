use Mix.Config

config :interface, InterfaceWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "../../interface/assets/node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../../../interface/assets", __DIR__)
    ]
  ],
  secret_key_base: "pOgEiGJWEsxiX3BmzCNGjiyVUDYG6HGnhzb9FBlG6EeGDiGm1x4tg0TBDqBWA432",
  live_view: [
    signing_salt: "qfAK1kcQLLci1GDPV7OvPF+/iLS+vS0f"
  ]

config :logger, level: :info

config :afk, keymap_file: "rootfs_overlay/etc/keymap.etf"

import_config "#{Mix.env()}.exs"
