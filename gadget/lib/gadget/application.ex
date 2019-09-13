defmodule Gadget.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = Gadget.Options.get()

    children = [
      {Gadget.GadgetDevices, opts},
      {Gadget.NetworkManager, opts},
      {Gadget.SSHConsole, opts}
    ]

    opts = [strategy: :one_for_one, name: Gadget.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
