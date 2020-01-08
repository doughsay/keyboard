use Mix.Config

config :logger, level: :info

config :afk, keymap_file: "rootfs_overlay/etc/keymap.etf"

import_config "#{Mix.env()}.exs"
