defmodule Firmware.KeymapServer do
  use GenServer

  alias Firmware.MatrixServer

  @keymap %{
    {0, 0} => :a,
    {1, 0} => :b,
    {0, 1} => :x,
    {1, 1} => :y
  }

  # Client

  def start_link(event_receiver) do
    GenServer.start_link(__MODULE__, %{
      event_receiver: event_receiver
    })
  end

  # Server

  @impl true
  def init(%{event_receiver: event_receiver}) do
    {:ok, _matrix} = MatrixServer.start_link(self())

    {:ok,
     %{
       event_receiver: event_receiver,
       keyset: []
     }}
  end

  @impl true
  def handle_info({:matrix_changed, matrix}, %{keyset: old_keyset} = state) do
    new_keyset = Enum.map(matrix, fn position -> @keymap[position] end)

    if new_keyset != old_keyset do
      send(state.event_receiver, {:keyset_changed, new_keyset})
    end

    {:noreply, %{state | keyset: new_keyset}}
  end
end
