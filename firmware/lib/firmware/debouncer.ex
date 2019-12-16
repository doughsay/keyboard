defmodule Firmware.Debouncer do
  use GenServer

  alias Firmware.MatrixServer

  # milliseconds
  @debounce_window 5

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
    |> Enum.each(fn event ->
      send(state.event_receiver, event)
    end)

    {:noreply, %{state | buffer: [], timer: nil}}
  end

  @impl true
  def handle_info({type, _key} = event, state) when type in ~w(key_pressed key_released)a do
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
