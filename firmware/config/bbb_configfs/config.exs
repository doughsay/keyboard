use Mix.Config

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

hostname = "keyboard.local"

config :excalibur, Excalibur.Interface.Endpoint,
  http: [port: 80, ip: {0, 0, 0, 0}],
  url: [host: hostname, port: 80],
  server: true,
  secret_key_base: "pOgEiGJWEsxiX3BmzCNGjiyVUDYG6HGnhzb9FBlG6EeGDiGm1x4tg0TBDqBWA432",
  live_view: [
    signing_salt: "qfAK1kcQLLci1GDPV7OvPF+/iLS+vS0f"
  ]

config :logger, backends: [RingLogger]

node_name = if Mix.env() != :prod, do: "excalibur"

config :gadget,
  ifname: "bond0",
  address_method: :dhcpd,
  mdns_domain: hostname,
  node_name: node_name,
  node_host: :mdns_domain

config :nerves_runtime, :kernel, use_system_registry: false

config :nerves_leds,
  names: [
    usr1: "beaglebone:green:usr0",
    usr2: "beaglebone:green:usr1",
    usr3: "beaglebone:green:usr2",
    usr4: "beaglebone:green:usr3"
  ]

config :afk, keymap_file: "/etc/keymap.etf"

import_config "#{Mix.env()}.exs"
