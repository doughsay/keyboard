require Logger

defmodule Firmware.HIDServer do
  use GenServer
  use Bitwise

  alias Firmware.MatrixServer

  @device "/dev/hidg0"

  # Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{device: @device})
  end

  # Server

  @impl true
  def init(%{device: device}) do
    {:ok, file} = File.open(device, [:write])
    {:ok, _matrix} = MatrixServer.start_link(self())

    modifier_state = 0x00
    key_state = %{}

    state = %{
      modifier_state: modifier_state,
      key_state: key_state,
      hid_file: file
    }

    write_hid(state)

    {:ok, state}
  end

  @impl true
  def handle_info({:keys_changed, keys}, state) do
    %{key_state: old_key_state} = state

    %{modifier: modifier_codes, key: key_codes} =
      Enum.group_by(keys, & &1.type, & &1.code)
      |> Map.put_new(:modifier, [])
      |> Map.put_new(:key, [])

    existing_codes = Map.keys(old_key_state)
    codes_to_remove = existing_codes -- key_codes

    new_key_state =
      Enum.reduce(codes_to_remove, old_key_state, fn code, acc ->
        Map.delete(acc, code)
      end)

    new_key_state =
      Enum.reduce(key_codes, new_key_state, fn code, acc ->
        if acc[code] do
          acc
        else
          case lowest_available_position(acc) do
            nil -> acc
            position -> Map.put(acc, code, position)
          end
        end
      end)

    new_modifier_state =
      Enum.reduce(modifier_codes, 0, fn code, acc ->
        acc ||| code
      end)

    new_state = %{state | key_state: new_key_state, modifier_state: new_modifier_state}

    if new_state != state do
      write_hid(new_state)
    end

    {:noreply, new_state}
  end

  defp lowest_available_position(key_state) do
    positions = MapSet.new([0, 1, 2, 3, 4, 5])

    positions =
      Enum.reduce(key_state, positions, fn {_code, position}, acc ->
        MapSet.delete(acc, position)
      end)

    Enum.min(positions, fn -> nil end)
  end

  defp write_hid(state) do
    codes_by_position = Map.new(state.key_state, fn {code, pos} -> {pos, code} end)

    key_report =
      [0, 1, 2, 3, 4, 5]
      |> Enum.map(fn pos ->
        case codes_by_position[pos] do
          nil -> 0
          x -> x
        end
      end)

    hid_report = ([state.modifier_state, 0x00] ++ key_report) |> List.to_string()

    Logger.debug(fn -> "HID state changed: " <> inspect(hid_report) end)

    IO.binwrite(state.hid_file, hid_report)
  end
end
