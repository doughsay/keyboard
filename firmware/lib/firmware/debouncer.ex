defmodule Firmware.Debouncer do
  use GenServer

  alias Firmware.KeyboardServer

  @debounce_window 5

  # Client

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def key_pressed(key) do
    GenServer.cast(__MODULE__, {:key_pressed, key})
  end

  def key_released(key) do
    GenServer.cast(__MODULE__, {:key_released, key})
  end

  # Server

  @impl true
  def init([]) do
    state = %{
      buffer: [],
      timer: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_info(:flush, state) do
    state.buffer
    |> Enum.reverse()
    |> Enum.uniq_by(fn {_type, key} -> key end)
    |> Enum.each(fn
      {:key_pressed, key} -> KeyboardServer.key_pressed(key)
      {:key_released, key} -> KeyboardServer.key_released(key)
    end)

    {:noreply, %{state | buffer: [], timer: nil}}
  end

  @impl true
  def handle_cast({type, _key} = event, state) when type in ~w(key_pressed key_released)a do
    state = set_debounce_timer(state)

    {:noreply, %{state | buffer: [event | state.buffer]}}
  end

  defp set_debounce_timer(%{timer: nil} = state) do
    %{state | timer: Process.send_after(self(), :flush, @debounce_window)}
  end

  defp set_debounce_timer(%{timer: timer} = state) do
    Process.cancel_timer(timer)
    set_debounce_timer(%{state | timer: nil})
  end
end
