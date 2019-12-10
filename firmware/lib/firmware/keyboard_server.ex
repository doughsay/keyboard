require Logger

defmodule Firmware.KeyboardServer do
  use GenServer
  use Bitwise

  alias Firmware.MatrixServer
  alias AFK.State

  @device "/dev/hidg0"

  # Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{device: @device})
  end

  # Server

  @impl true
  def init(%{device: device}) do
    {:ok, _matrix} = MatrixServer.start_link(self())

    keymap_file = Application.fetch_env!(:afk, :keymap_file)
    keymap = AFK.Keymap.load_from_file!(keymap_file)

    %{
      keyboard_state: State.new(keymap),
      hid_file: File.open!(device, [:write])
    }
    |> write_hid()
    |> ok()
  end

  @impl true
  def handle_info({:key_pressed, key}, state) do
    state
    |> press_key(key)
    |> write_hid()
    |> broadcast()
    |> noreply()
  end

  @impl true
  def handle_info({:key_released, key}, state) do
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
