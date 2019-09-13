defmodule Gadget.Options do
  @moduledoc false

  alias Gadget.Options

  defstruct ifname: "usb0",
            address_method: :dhcpd,
            mdns_domain: "nerves.local",
            node_name: nil,
            node_host: :mdns_domain,
            ssh_console_port: 22

  def get() do
    :gadget
    |> Application.get_all_env()
    |> Enum.into(%{})
    |> merge_defaults()
  end

  defp merge_defaults(settings) do
    Map.merge(%Options{}, settings)
  end
end
