use Mix.Config

config :excalibur, Excalibur.Interface.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../../assets", __DIR__)
    ]
  ],
  secret_key_base: "pOgEiGJWEsxiX3BmzCNGjiyVUDYG6HGnhzb9FBlG6EeGDiGm1x4tg0TBDqBWA432",
  live_view: [
    signing_salt: "qfAK1kcQLLci1GDPV7OvPF+/iLS+vS0f"
  ]

# Watch static and templates for browser reloading.
config :excalibur, Excalibur.Interface.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/interface_web/{live,views}/.*(ex)$",
      ~r"lib/interface_web/templates/.*(eex)$"
    ]
  ]

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
