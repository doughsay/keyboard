defmodule Firmware.HIDServer do
  use GenServer

  alias Firmware.KeymapServer

  @device "/dev/hidg0"

  @keys %{
    kc_a: 0x04,
    kc_b: 0x05,
    kc_c: 0x06,
    kc_d: 0x07,
    kc_e: 0x08,
    kc_f: 0x09,
    kc_g: 0x0A,
    kc_h: 0x0B,
    kc_i: 0x0C,
    kc_j: 0x0D,
    kc_k: 0x0E,
    kc_l: 0x0F,
    kc_m: 0x10,
    kc_n: 0x11,
    kc_o: 0x12,
    kc_p: 0x13,
    kc_q: 0x14,
    kc_r: 0x15,
    kc_s: 0x16,
    kc_t: 0x17,
    kc_u: 0x18,
    kc_v: 0x19,
    kc_w: 0x1A,
    kc_x: 0x1B,
    kc_y: 0x1C,
    kc_z: 0x1D,
    kc_1: 0x1E,
    kc_2: 0x1F,
    kc_3: 0x20,
    kc_4: 0x21,
    kc_5: 0x22,
    kc_6: 0x23,
    kc_7: 0x24,
    kc_8: 0x25,
    kc_9: 0x26,
    kc_0: 0x27,
    kc_ent: 0x28,
    kc_esc: 0x29,
    kc_bspc: 0x2A,
    kc_tab: 0x2B,
    kc_spc: 0x2C,
    kc_mins: 0x2D,
    kc_eql: 0x2E,
    kc_lbrc: 0x2F,
    kc_rbrc: 0x30,
    kc_bsls: 0x31,
    kc_nuhs: 0x32,
    kc_scln: 0x33,
    kc_quot: 0x34,
    kc_grv: 0x35,
    kc_comm: 0x36,
    kc_dot: 0x37,
    kc_slsh: 0x38,
    kc_clck: 0x39,
    kc_f1: 0x3A,
    kc_f2: 0x3B,
    kc_f3: 0x3C,
    kc_f4: 0x3D,
    kc_f5: 0x3E,
    kc_f6: 0x3F,
    kc_f7: 0x40,
    kc_f8: 0x41,
    kc_f9: 0x42,
    kc_f10: 0x43,
    kc_f11: 0x44,
    kc_f12: 0x45,
    kc_pscr: 0x46,
    kc_slck: 0x47,
    kc_paus: 0x48,
    kc_ins: 0x49,
    kc_home: 0x4A,
    kc_pgup: 0x4B,
    kc_del: 0x4C,
    kc_end: 0x4D,
    kc_pgdn: 0x4E,
    kc_rght: 0x4F,
    kc_left: 0x50,
    kc_down: 0x51,
    kc_up: 0x52,
    # snip
    kc_app: 0x65
  }

  @modifiers %{
    kc_lctl: 0x01,
    kc_lsft: 0x02,
    kc_lalt: 0x04,
    kc_lspr: 0x08,
    kc_rctl: 0x10,
    kc_rsft: 0x20,
    kc_ralt: 0x40,
    kc_rspr: 0x80
  }

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, %{device: @device})
  end

  # Server

  @impl true
  def init(%{device: device}) do
    {:ok, file} = File.open(device, [:write])
    {:ok, _keymap} = KeymapServer.start_link(self())

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
  def handle_info({:keyset_changed, keyset}, %{key_state: old_key_state} = state) do
    code_set = Enum.map(keyset, fn key -> @keys[key] end)

    existing_codes = Map.keys(old_key_state)
    codes_to_remove = existing_codes -- code_set

    new_key_state =
      Enum.reduce(codes_to_remove, old_key_state, fn code, acc ->
        Map.delete(acc, code)
      end)

    new_key_state =
      Enum.reduce(code_set, new_key_state, fn code, acc ->
        if acc[code] do
          acc
        else
          case lowest_available_position(acc) do
            nil -> acc
            position -> Map.put(acc, code, position)
          end
        end
      end)

    new_state = %{state | key_state: new_key_state}

    if new_key_state != old_key_state do
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
    IO.binwrite(state.hid_file, hid_report)
  end
end
