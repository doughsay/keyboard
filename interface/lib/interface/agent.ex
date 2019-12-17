defmodule Interface.Agent do
  use Agent

  defmodule MockKeyboardServer do
    def get_state do
      AFK.State.new([])
    end
  end

  def start_link([]) do
    default_state = %{
      keymap: [],
      keyboard_server: MockKeyboardServer
    }

    Agent.start_link(fn -> default_state end, name: __MODULE__)
  end

  def set_keymap(keymap) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, :keymap, keymap)
    end)
  end

  def set_keyboard_server(server) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, :keyboard_server, server)
    end)
  end

  def keymap do
    Agent.get(__MODULE__, & &1.keymap)
  end

  def keyboard_server do
    Agent.get(__MODULE__, & &1.keyboard_server)
  end
end
