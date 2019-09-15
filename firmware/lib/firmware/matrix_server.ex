defmodule Firmware.MatrixServer do
  use GenServer

  alias Circuits.GPIO

  @refresh_rate_hz 50

  @row1_pin 58
  @row2_pin 60
  @col1_pin 47
  @col2_pin 46

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
    {:ok, row1} = GPIO.open(@row1_pin, :output, initial_value: 0)
    {:ok, row2} = GPIO.open(@row2_pin, :output, initial_value: 0)
    {:ok, col1} = GPIO.open(@col1_pin, :input)
    {:ok, col2} = GPIO.open(@col2_pin, :input)

    Process.send_after(self(), :tick, div(rate, 1_000))

    {:ok,
     %{
       event_receiver: event_receiver,
       rate: rate,
       last_run_time: :os.system_time(:microsecond),
       rows: [row1, row2],
       cols: [col1, col2],
       previous_matrix: [[0, 0], [0, 0]]
     }}
  end

  @impl true
  def handle_info(:tick, %{rate: rate, last_run_time: last_run_time} = state) do
    before_work = :os.system_time(:microsecond)

    matrix = scan(state)

    if matrix != state.previous_matrix do
      send(state.event_receiver, {:matrix_changed, matrix})
    end

    after_work = :os.system_time(:microsecond)

    schedule_drift = before_work - last_run_time - rate
    work_drift = after_work - before_work
    total_drift = schedule_drift + work_drift
    delay_ms = (rate - total_drift) |> div(1_000)

    Process.send_after(self(), :tick, delay_ms)

    {:noreply, %{state | last_run_time: before_work - schedule_drift, previous_matrix: matrix}}
  end

  defp scan(state) do
    for row <- state.rows do
      GPIO.write(row, 1)

      cols =
        for col <- state.cols do
          GPIO.read(col)
        end

      GPIO.write(row, 0)

      cols
    end
  end
end
