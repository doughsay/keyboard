require Logger

defmodule Firmware.MatrixServer do
  use GenServer

  alias Circuits.GPIO
  alias Firmware.{Keyboard, Utils}

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
    keycode_map = Keyboard.switch_to_keycode_map()

    matrix_layout =
      Keyboard.matrix_layout()
      |> Utils.pad_matrix()
      |> Enum.zip()
      |> Enum.map(fn col ->
        col
        |> Tuple.to_list()
        |> Enum.filter(& &1)
        |> Enum.map(&Map.fetch!(keycode_map, &1))
      end)

    row_pins = Keyboard.row_pins() |> Enum.map(&open_input_pin!/1)
    col_pins = Keyboard.col_pins() |> Enum.map(&open_output_pin!/1)

    Enum.zip(
      col_pins,
      Enum.map(matrix_layout, fn col ->
        Enum.zip(row_pins, col)
      end)
    )
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
      Logger.debug(fn -> "Keys changed: " <> inspect(keys) end)

      send(state.event_receiver, {:keys_changed, keys})
    end

    send(self(), :scan)

    {:noreply, %{state | previous_keys: keys}}
  end

  defp scan(matrix_config) do
    Enum.reduce(matrix_config, [], fn {col_pin, rows}, acc ->
      with_pin_high(col_pin, fn ->
        Enum.reduce(rows, acc, fn {row_pin, key_id}, acc ->
          case pin_high?(row_pin) do
            true -> [key_id | acc]
            false -> acc
          end
        end)
      end)
    end)
  end

  defp with_pin_high(pin, fun) do
    :ok = GPIO.write(pin, 1)
    response = fun.()
    :ok = GPIO.write(pin, 0)
    response
  end

  defp pin_high?(pin) do
    GPIO.read(pin) == 1
  end
end
