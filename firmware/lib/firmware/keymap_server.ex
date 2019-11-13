defmodule Firmware.KeymapServer do
  use GenServer

  alias Firmware.MatrixServer

  # Client

  def start_link(event_receiver) do
    GenServer.start_link(__MODULE__, event_receiver)
  end

  # Server

  @impl true
  def init(event_receiver) do
    {:ok, _matrix} = MatrixServer.start_link(self())

    state = %{
      event_receiver: event_receiver,
      switch_to_keycode_map: Keyboard.switch_to_keycode_map()
    }

    {:ok, state}
  end

  @impl true
  def handle_info({:keys_changed, keys}, state) do
    Interface.broadcast("keyboard", {:keys_changed, keys})

    keycodes = Enum.map(keys, fn key_id -> state.switch_to_keycode_map[key_id] end)
    send(state.event_receiver, {:keycodes_changed, keycodes})

    {:noreply, state}
  end
end
