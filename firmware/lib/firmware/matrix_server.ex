require Logger

defmodule Firmware.MatrixServer do
  use GenServer

  alias Circuits.GPIO

  @refresh_rate_hz 100

  @row_pins [58, 60]
  @col_pins [47, 46]

  # Client

  def start_link(event_receiver) do
    GenServer.start_link(__MODULE__, %{
      rate: div(1_000_000, @refresh_rate_hz),
      event_receiver: event_receiver
    })
  end

  # Server

  @impl true
  def init(%{rate: rate, event_receiver: event_receiver}) do
    Process.send_after(self(), :tick, div(rate, 1_000))

    {:ok,
     %{
       event_receiver: event_receiver,
       rate: rate,
       last_run_time: :os.system_time(:microsecond),
       rows: init_row_pins(),
       cols: init_col_pins(),
       previous_matrix: []
     }}
  end

  defp init_row_pins do
    @row_pins
    |> Enum.map(fn pin ->
      {:ok, ref} = GPIO.open(pin, :output, initial_value: 0)
      ref
    end)
    |> Enum.with_index()
  end

  defp init_col_pins do
    @col_pins
    |> Enum.map(fn pin ->
      {:ok, ref} = GPIO.open(pin, :input)
      ref
    end)
    |> Enum.with_index()
  end

  @impl true
  def handle_info(:tick, %{rate: rate, last_run_time: last_run_time} = state) do
    before_work = :os.system_time(:microsecond)
    matrix = do_tick(state)
    after_work = :os.system_time(:microsecond)

    schedule_drift = before_work - last_run_time - rate
    work_drift = after_work - before_work
    total_drift = schedule_drift + work_drift
    delay_ms = (rate - total_drift) |> div(1_000)

    if delay_ms <= 0 do
      Logger.warn("#{__MODULE__} behind by #{delay_ms}ms in matrix scanning!")
      send(self(), :tick)
    else
      Process.send_after(self(), :tick, delay_ms)
    end

    {:noreply, %{state | last_run_time: before_work - schedule_drift, previous_matrix: matrix}}
  end

  defp do_tick(state) do
    matrix = scan(state)

    if matrix != state.previous_matrix do
      send(state.event_receiver, {:matrix_changed, matrix})
    end

    matrix
  end

  defp scan(state) do
    Enum.reduce(state.rows, [], fn {row, row_idx}, acc ->
      GPIO.write(row, 1)

      acc =
        Enum.reduce(state.cols, acc, fn {col, col_idx}, acc ->
          if GPIO.read(col) == 1 do
            [{col_idx, row_idx} | acc]
          else
            acc
          end
        end)

      GPIO.write(row, 0)

      acc
    end)
    |> Enum.reverse()
  end
end
