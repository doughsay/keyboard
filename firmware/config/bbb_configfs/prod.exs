use Mix.Config

config :logger,
  level: :info,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

live_view_signing_salt =
  System.get_env("LIVE_VIEW_SIGNING_SALT") ||
    raise """
    environment variable LIVE_VIEW_SIGNING_SALT is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :firmware, InterfaceWeb.Endpoint,
  secret_key_base: secret_key_base,
  live_view: [
    signing_salt: live_view_signing_salt
  ]
