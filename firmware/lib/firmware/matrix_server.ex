require Logger

defmodule Firmware.MatrixServer do
  use GenServer

  alias Circuits.GPIO

  # Client

  def start_link(event_receiver) do
    GenServer.start_link(__MODULE__, event_receiver)
  end

  # Server

  @impl true
  def init(event_receiver) do
    state = %{
      event_receiver: event_receiver,
      matrix_config: init_matrix_config(),
      previous_keys: []
    }

    send(self(), :scan)

    {:ok, state}
  end

  defp init_matrix_config do
    matrix_layout =
      Application.fetch_env!(:firmware, :matrix_layout)
      |> Firmware.Layout.parse!()
      |> pad_matrix()
      |> Enum.zip()
      |> Enum.map(fn col ->
        col |> Tuple.to_list() |> Enum.filter(& &1)
      end)

    row_pins =
      Application.fetch_env!(:firmware, :row_pins)
      |> Enum.map(&open_input_pin!/1)

    col_pins =
      Application.fetch_env!(:firmware, :col_pins)
      |> Enum.map(&open_output_pin!/1)

    Enum.zip(
      col_pins,
      Enum.map(matrix_layout, fn col ->
        Enum.zip(row_pins, col)
      end)
    )
  end

  defp pad_matrix([first | _rest] = matrix) do
    length = Enum.count(first)

    Enum.map(matrix, fn row ->
      if Enum.count(row) != length do
        [[], padded] =
          Enum.reduce(1..length, [row, []], fn
            _, [[], acc] -> [[], [nil | acc]]
            _, [[next | rest], acc] -> [rest, [next | acc]]
          end)

        Enum.reverse(padded)
      else
        row
      end
    end)
  end

  defp open_input_pin!(pin_number) do
    {:ok, ref} = GPIO.open(pin_number, :input)
    ref
  end

  defp open_output_pin!(pin_number) do
    {:ok, ref} = GPIO.open(pin_number, :output, initial_value: 0)
    ref
  end

  @impl true
  def handle_info(:scan, state) do
    keys = scan(state.matrix_config)

    if keys != state.previous_keys do
      send(state.event_receiver, {:keys_changed, keys})
    end

    send(self(), :scan)

    {:noreply, %{state | previous_keys: keys}}
  end

  defp scan(matrix_config) do
    Enum.reduce(matrix_config, [], fn {col_pin, rows}, acc ->
      GPIO.write(col_pin, 1)

      acc =
        Enum.reduce(rows, acc, fn {row_pin, key_id}, acc ->
          if GPIO.read(row_pin) == 1 do
            [key_id | acc]
          else
            acc
          end
        end)

      GPIO.write(col_pin, 0)

      acc
    end)
  end
end
