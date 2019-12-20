require Logger

defmodule Firmware.MockMatrixServer do
  use GenServer

  alias Firmware.KeyboardServer

  @event_frequency 250

  # Client

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def reset! do
    GenServer.call(__MODULE__, :reset!)
  end

  # Server

  @impl true
  def init([]) do
    state = %{
      held_keys: [],
      possible_keys:
        Enum.map(1..68, fn n ->
          String.to_atom("k" <> String.pad_leading(to_string(n), 3, "0"))
        end)
    }

    Process.send_after(self(), :scan, @event_frequency)

    {:ok, state}
  end

  @impl true
  def handle_call(:reset!, _from, state) do
    state = %{state | held_keys: []}

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:scan, state) do
    n = Enum.count(state.held_keys)

    keys =
      cond do
        n == 0 ->
          [Enum.random(state.possible_keys)]

        :rand.uniform(n) <= 5 ->
          # add a key
          missing_keys = state.possible_keys -- state.held_keys
          key = Enum.random(missing_keys)
          [key | state.held_keys] |> Enum.sort()

        true ->
          # remove a key
          key = Enum.random(state.held_keys)
          List.delete(state.held_keys, key)
      end

    removed = state.held_keys -- keys
    added = keys -- state.held_keys

    Enum.each(removed, fn key ->
      Logger.debug(fn -> "Key released: #{key}" end)

      KeyboardServer.key_released(key)
    end)

    Enum.each(added, fn key ->
      Logger.debug(fn -> "Key pressed: #{key}" end)

      KeyboardServer.key_pressed(key)
    end)

    Process.send_after(self(), :scan, @event_frequency)

    {:noreply, %{state | held_keys: keys}}
  end
end
