defmodule Excalibur.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    keymap_file = Application.fetch_env!(:afk, :keymap_file)
    keymap = AFK.Keymap.load_from_file!(keymap_file)

    opts = [strategy: :one_for_all, name: Excalibur.Supervisor]

    children = children(target(), keymap)

    response = Supervisor.start_link(children, opts)

    response
  end

  def children(:host, keymap) do
    [
      # Children that only run on the host
      {Excalibur.Firmware.KeyboardServer, [device_path: "/dev/null", keymap: keymap]},
      Excalibur.Firmware.MockMatrixServer,
      Excalibur.Interface.Endpoint
    ]
  end

  def children(_target, keymap) do
    [
      # Children for all targets except host
      {Excalibur.Firmware.KeyboardServer, [keymap: keymap]},
      Excalibur.Firmware.MatrixServer,
      Excalibur.Interface.Endpoint
    ]
  end

  def target() do
    Application.get_env(:excalibur, :target)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Excalibur.Interface.Endpoint.config_change(changed, removed)
    :ok
  end
end
