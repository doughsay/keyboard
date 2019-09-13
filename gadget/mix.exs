defmodule Gadget.MixProject do
  use Mix.Project

  def project do
    [
      app: :gadget,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gadget.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves_runtime, "~> 0.3"},
      {:nerves_network, "~> 0.3"},
      {:nerves_firmware_ssh, "~> 0.2"},
      {:nerves_time, "~> 0.2"},
      {:mdns, "~> 1.0"},
      {:ring_logger, "~> 0.4"},
      {:one_dhcpd, "~> 0.1"},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:usb_gadget, github: "nerves-project/usb_gadget", ref: "master"}
    ]
  end
end
