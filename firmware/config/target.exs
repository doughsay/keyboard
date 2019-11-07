use Mix.Config

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

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

# Setting the node_name will enable Erlang Distribution.
# Only enable this for prod if you understand the risks.
node_name = if Mix.env() != :prod, do: "firmware"

config :gadget,
  ifname: "bond0",
  address_method: :dhcpd,
  mdns_domain: "keyboard.local",
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

config :firmware,
  row_pins: [87, 89, 20, 26, 59, 58, 57, 86],
  col_pins: [45, 27, 65, 23, 44, 46, 64, 47, 52],
  matrix_layout: File.read!("config/matrix_layout.txt"),
  switch_layout: File.read!("config/switch_layout.txt")

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
