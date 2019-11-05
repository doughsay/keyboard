require Logger

defmodule Firmware.MatrixServer do
  use GenServer

  alias Circuits.GPIO

  # Client

  def start_link(event_receiver) do
    GenServer.start_link(__MODULE__, event_receiver)
  end

  # Config

  defp row_pins do
    Application.fetch_env!(:firmware, :row_pins)
  end

  defp col_pins do
    Application.fetch_env!(:firmware, :col_pins)
  end

  # Server

  @impl true
  def init(event_receiver) do
    state = %{
      event_receiver: event_receiver,
      rows: init_row_pins(),
      cols: init_col_pins(),
      previous_matrix: []
    }

    send(self(), :tick)

    {:ok, state}
  end

  defp init_row_pins do
    row_pins()
    |> Enum.map(fn pin ->
      {:ok, ref} = GPIO.open(pin, :input)
      ref
    end)
    |> Enum.with_index()
  end

  defp init_col_pins do
    col_pins()
    |> Enum.map(fn pin ->
      {:ok, ref} = GPIO.open(pin, :output, initial_value: 0)
      ref
    end)
    |> Enum.with_index()
  end

  @impl true
  def handle_info(:tick, state) do
    matrix = scan(state)

    if matrix != state.previous_matrix do
      send(state.event_receiver, {:matrix_changed, matrix})
    end

    send(self(), :tick)

    {:noreply, %{state | previous_matrix: matrix}}
  end

  defp scan(state) do
    Enum.reduce(state.cols, [], fn {col, col_idx}, acc ->
      GPIO.write(col, 1)

      acc =
        Enum.reduce(state.rows, acc, fn {row, row_idx}, acc ->
          if GPIO.read(row) == 1 do
            [{col_idx, row_idx} | acc]
          else
            acc
          end
        end)

      GPIO.write(col, 0)

      acc
    end)
    |> Enum.reverse()
  end
end
