require Logger

defmodule Firmware.MatrixServer do
  use GenServer

  alias Circuits.GPIO

  # Client

  def start_link(event_receiver) do
    GenServer.start_link(__MODULE__, event_receiver)
  end

  # Config

  defp refresh_rate do
    Application.fetch_env!(:firmware, :refresh_rate)
  end

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
      started: DateTime.utc_now(),
      scan_count: 0,
      event_receiver: event_receiver,
      rate: div(1_000_000, refresh_rate()),
      last_run_time: :os.system_time(:microsecond),
      rows: init_row_pins(),
      cols: init_col_pins(),
      previous_matrix: []
    }

    Process.send_after(self(), :tick, div(state.rate, 1_000))
    # FIXME: remove me
    Process.send_after(self(), :report, 10_000)

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
  def handle_info(:report, state) do
    since_start = DateTime.diff(DateTime.utc_now(), state.started, :microsecond)
    seconds = since_start / 1_000_000
    rate = state.scan_count / seconds
    display_rate = Float.round(rate, 3)
    Logger.info("Matrix Scan Rate: #{display_rate}hz")

    Process.send_after(self(), :report, 10_000)

    {:noreply, state}
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
      send(self(), :tick)
    else
      Process.send_after(self(), :tick, delay_ms)
    end

    {:noreply,
     %{
       state
       | last_run_time: before_work - schedule_drift,
         previous_matrix: matrix,
         scan_count: state.scan_count + 1
     }}
  end

  defp do_tick(state) do
    matrix = scan(state)

    if matrix != state.previous_matrix do
      send(state.event_receiver, {:matrix_changed, matrix})
    end

    matrix
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
