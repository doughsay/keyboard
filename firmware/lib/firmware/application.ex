defmodule Firmware.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    keymap_file = Application.fetch_env!(:afk, :keymap_file)
    keymap = AFK.Keymap.load_from_file!(keymap_file)

    opts = [strategy: :one_for_all, name: Firmware.Supervisor]

    children =
      [
        # Children for all targets
      ] ++ children(target(), keymap)

    response = Supervisor.start_link(children, opts)

    Interface.Agent.set_keymap(keymap)
    Interface.Agent.set_keyboard_server(Firmware.KeyboardServer)

    response
  end

  def children(:host, keymap) do
    [
      # Children that only run on the host
      {Firmware.KeyboardServer, [device_path: "/dev/null", keymap: keymap]},
      Firmware.MockMatrixServer
    ]
  end

  def children(_target, keymap) do
    [
      # Children for all targets except host
      {Firmware.KeyboardServer, [keymap: keymap]},
      Firmware.MatrixServer
    ]
  end

  def target() do
    Application.get_env(:firmware, :target)
  end
end
