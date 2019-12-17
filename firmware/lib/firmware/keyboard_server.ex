require Logger

defmodule Firmware.KeyboardServer do
  use GenServer
  use Bitwise

  alias AFK.State

  @default_device_path "/dev/hidg0"

  # Client

  def start_link(opts) do
    device_path = Keyword.get(opts, :device_path, @default_device_path)
    keymap = Keyword.fetch!(opts, :keymap)

    config = %{
      device_path: device_path,
      keymap: keymap
    }

    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def key_pressed(key) do
    GenServer.cast(__MODULE__, {:key_pressed, key})
  end

  def key_released(key) do
    GenServer.cast(__MODULE__, {:key_released, key})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  # Server

  @impl true
  def init(%{device_path: device_path, keymap: keymap}) do
    %{
      keyboard_state: State.new(keymap),
      hid_file: File.open!(device_path, [:write])
    }
    |> write_hid()
    |> ok()
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state.keyboard_state, state}
  end

  @impl true
  def handle_cast({:key_pressed, key}, state) do
    state
    |> press_key(key)
    |> write_hid()
    |> broadcast()
    |> noreply()
  end

  @impl true
  def handle_cast({:key_released, key}, state) do
    state
    |> release_key(key)
    |> write_hid()
    |> broadcast()
    |> noreply()
  end

  defp press_key(state, key) do
    keyboard_state = State.press_key(state.keyboard_state, key)

    %{state | keyboard_state: keyboard_state}
  end

  defp release_key(state, key) do
    keyboard_state = State.release_key(state.keyboard_state, key)

    %{state | keyboard_state: keyboard_state}
  end

  defp write_hid(state) do
    hid_report = State.to_hid_report(state.keyboard_state)

    Logger.debug(fn -> "HID state changed: " <> inspect(hid_report) end)

    IO.binwrite(state.hid_file, hid_report)

    state
  end

  defp broadcast(state) do
    Interface.broadcast("keyboard", {:state_changed, state.keyboard_state})

    state
  end

  defp ok(state), do: {:ok, state}
  defp noreply(state), do: {:noreply, state}
end
