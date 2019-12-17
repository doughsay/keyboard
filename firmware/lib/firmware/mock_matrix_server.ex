require Logger

defmodule Firmware.MockMatrixServer do
  use GenServer

  alias Firmware.KeyboardServer

  @event_frequency 250

  # Client

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  # Server

  @impl true
  def init([]) do
    state = %{
      possible_keys:
        Enum.map(1..68, fn n ->
          String.to_atom("k" <> String.pad_leading(to_string(n), 3, "0"))
        end),
      previous_keys: []
    }

    Process.send_after(self(), :scan, @event_frequency)

    {:ok, state}
  end

  @impl true
  def handle_info(:scan, state) do
    n = Enum.count(state.previous_keys)

    keys =
      cond do
        n == 0 ->
          [Enum.random(state.possible_keys)]

        :rand.uniform(n) <= 5 ->
          # add a key
          missing_keys = state.possible_keys -- state.previous_keys
          key = Enum.random(missing_keys)
          [key | state.previous_keys] |> Enum.sort()

        true ->
          # remove a key
          key = Enum.random(state.previous_keys)
          List.delete(state.previous_keys, key)
      end

    removed = state.previous_keys -- keys
    added = keys -- state.previous_keys

    Enum.each(removed, fn key ->
      Logger.debug(fn -> "Key released: #{key}" end)

      KeyboardServer.key_released(key)
    end)

    Enum.each(added, fn key ->
      Logger.debug(fn -> "Key pressed: #{key}" end)

      KeyboardServer.key_pressed(key)
    end)

    Process.send_after(self(), :scan, @event_frequency)

    {:noreply, %{state | previous_keys: keys}}
  end
end
