defmodule Keyboard.Config do
  @moduledoc """
  Parses and loads various kinds of config strings into keyboard config data
  structures.
  """

  # alias Keyboard.Keycode
  alias __MODULE__.Parser

  # The GPIO pin IDs that are connected to the matrix rows
  @row_pins [87, 89, 20, 26, 59, 58, 57, 86]

  # The GPIO pin IDs that are connected to the matrix columns
  @col_pins [45, 27, 65, 23, 44, 46, 64, 47, 52]

  # This is the electrical layout of the matrix of the keyboard. The rows and
  # columns here map directly to row and column GPIO pins on the controller.
  @matrix_layout """
                 k001 k002 k003 k004 k005 k006 k007 k008 k009
                 k010 k011 k012 k013 k014 k015 k016 k017 k018
                 k019 k020 k021 k022 k023 k024 k025 k026 k027
                 k028 k029 k030 k031 k032 k033 k034 k035 k036
                 k037 k038 k039 k040 k041 k042 k043 k044 k045
                 k046 k047 k048 k049 k050 k051 k052 k053 k054
                 k055 k056 k057 k058 k059 k060 k061 k062 k063
                 k064 k065 k066 k067 k068
                 """
                 |> Parser.parse!()

  # # This is the physical layout of the switches on the keyboard.
  # @switch_layout """
  #                k001 k002 k003 k004 k005 k006 k007 k008 k009 k010 k011 k012 k013 k014  k015 k016
  #                k017 k018 k019 k020 k021 k022 k023 k024 k025 k026 k027 k028 k029 k030  k031 k032
  #                k033 k034 k035 k036 k037 k038 k039 k040 k041 k042 k043 k044 k045
  #                k046 k047 k048 k049 k050 k051 k052 k053 k054 k055 k056 k057            k058
  #                k059 k060 k061                  k062              k063 k064 k065  k066 k067 k068
  #                """
  #                |> Parser.parse!()

  @doc """
  Returns the list of GPIO row pin IDs.

  ## Example

      iex> row_pins()
      [87, 89, 20, 26, 59, 58, 57, 86]
  """
  def row_pins, do: @row_pins

  @doc """
  Returns the list of GPIO column pin IDs.

  ## Example

      iex> col_pins()
      [45, 27, 65, 23, 44, 46, 64, 47, 52]
  """
  def col_pins, do: @col_pins

  @doc """
  Returns the layout of the electrical matrix of the keyboard.

  ## Example

      iex> matrix_layout()
      [
        [:k001, :k002, :k003, :k004, :k005, :k006, :k007, :k008, :k009],
        [:k010, :k011, :k012, :k013, :k014, :k015, :k016, :k017, :k018],
        [:k019, :k020, :k021, :k022, :k023, :k024, :k025, :k026, :k027],
        [:k028, :k029, :k030, :k031, :k032, :k033, :k034, :k035, :k036],
        [:k037, :k038, :k039, :k040, :k041, :k042, :k043, :k044, :k045],
        [:k046, :k047, :k048, :k049, :k050, :k051, :k052, :k053, :k054],
        [:k055, :k056, :k057, :k058, :k059, :k060, :k061, :k062, :k063],
        [:k064, :k065, :k066, :k067, :k068]
      ]
  """
  def matrix_layout, do: @matrix_layout

  # @doc """
  # Returns the layout of the physical switches of the keyboard.

  # ## Example

  #     iex> switch_layout()
  #     [
  #       [:k001, :k002, :k003, :k004, :k005, :k006, :k007, :k008, :k009, :k010, :k011, :k012, :k013, :k014, :k015, :k016],
  #       [:k017, :k018, :k019, :k020, :k021, :k022, :k023, :k024, :k025, :k026, :k027, :k028, :k029, :k030, :k031, :k032],
  #       [:k033, :k034, :k035, :k036, :k037, :k038, :k039, :k040, :k041, :k042, :k043, :k044, :k045],
  #       [:k046, :k047, :k048, :k049, :k050, :k051, :k052, :k053, :k054, :k055, :k056, :k057, :k058],
  #       [:k059, :k060, :k061, :k062, :k063, :k064, :k065, :k066, :k067, :k068]
  #     ]
  # """
  # def switch_layout, do: @switch_layout

  # @doc """
  # Returns the name of the current keymap.

  # ## Example

  #     iex> current_keymap_name()
  #     "default"
  # """
  # def current_keymap_name,
  #   do: Application.fetch_env!(:keyboard, :current_keymap_file) |> File.read!() |> String.trim()

  # @doc """
  # Returns the current keymap.

  # ## Example

  #     iex> current_keymap()
  #     [
  #       [:kc_esc, :kc_1, :kc_2, :kc_3, :kc_4, :kc_5, :kc_6, :kc_7, :kc_8, :kc_9, :kc_0, :kc_mins, :kc_eql, :kc_bspc, :kc_home, :kc_pgup],
  #       [:kc_tab, :kc_q, :kc_w, :kc_e, :kc_r, :kc_t, :kc_y, :kc_u, :kc_i, :kc_o, :kc_p, :kc_lbrc, :kc_rbrc, :kc_bsls, :kc_end, :kc_pgdn],
  #       [:kc_grv, :kc_a, :kc_s, :kc_d, :kc_f, :kc_g, :kc_h, :kc_j, :kc_k, :kc_l, :kc_scln, :kc_quot, :kc_ent],
  #       [:kc_lsft, :kc_z, :kc_x, :kc_c, :kc_v, :kc_b, :kc_n, :kc_m, :kc_comm, :kc_dot, :kc_slsh, :kc_rsft, :kc_up],
  #       [:kc_lctl, :kc_lspr, :kc_lalt, :kc_spc, :kc_ralt, :kc_rspr, :kc_rctl, :kc_left, :kc_down, :kc_rght]
  #     ]
  # """
  # def current_keymap do
  #   keymaps_path = Application.fetch_env!(:keyboard, :keymaps_path)
  #   current_keymap = current_keymap_name()

  #   Path.join(keymaps_path, current_keymap)
  #   |> File.read!()
  #   |> Parser.parse!()
  # end

  alias Keyboard.Keycodes.{Key, Modifier, Layer, None, Transparent}

  @doc """
  Returns a map of switch IDs to `Keyboard.Keycode`s.

  ## Example

      iex> map = switch_to_keycode_map()
      ...> hd(map)[:k001]
      #Keyboard.Keycodes.Key<Escape>

      iex> map = switch_to_keycode_map()
      ...> hd(map)[:k046]
      #Keyboard.Keycodes.Modifier<Left Shift>
  """
  def switch_to_keycode_map do
    # Enum.zip(switch_layout(), current_keymap())
    # |> Enum.flat_map(fn {layout_row, keymap_row} ->
    #   keycodes = Enum.map(keymap_row, &Keycode.from_id!/1)
    #   Enum.zip(layout_row, keycodes)
    # end)
    # |> Map.new()
    [
      %{
        k001: Key.from_id!(:kc_esc),
        k002: Key.from_id!(:kc_1),
        k003: Key.from_id!(:kc_2),
        k004: Key.from_id!(:kc_3),
        k005: Key.from_id!(:kc_4),
        k006: Key.from_id!(:kc_5),
        k007: Key.from_id!(:kc_6),
        k008: Key.from_id!(:kc_7),
        k009: Key.from_id!(:kc_8),
        k010: Key.from_id!(:kc_9),
        k011: Key.from_id!(:kc_0),
        k012: Key.from_id!(:kc_mins),
        k013: Key.from_id!(:kc_eql),
        k014: Key.from_id!(:kc_bspc),
        k015: Key.from_id!(:kc_home),
        k016: Key.from_id!(:kc_pgup),
        k017: Key.from_id!(:kc_tab),
        k018: Key.from_id!(:kc_q),
        k019: Key.from_id!(:kc_w),
        k020: Key.from_id!(:kc_e),
        k021: Key.from_id!(:kc_r),
        k022: Key.from_id!(:kc_t),
        k023: Key.from_id!(:kc_y),
        k024: Key.from_id!(:kc_u),
        k025: Key.from_id!(:kc_i),
        k026: Key.from_id!(:kc_o),
        k027: Key.from_id!(:kc_p),
        k028: Key.from_id!(:kc_lbrc),
        k029: Key.from_id!(:kc_rbrc),
        k030: Key.from_id!(:kc_bsls),
        k031: Key.from_id!(:kc_end),
        k032: Key.from_id!(:kc_pgdn),
        k033: Key.from_id!(:kc_grv),
        k034: Key.from_id!(:kc_a),
        k035: Key.from_id!(:kc_s),
        k036: Key.from_id!(:kc_d),
        k037: Key.from_id!(:kc_f),
        k038: Key.from_id!(:kc_g),
        k039: Key.from_id!(:kc_h),
        k040: Key.from_id!(:kc_j),
        k041: Key.from_id!(:kc_k),
        k042: Key.from_id!(:kc_l),
        k043: Key.from_id!(:kc_scln),
        k044: Key.from_id!(:kc_quot),
        k045: Key.from_id!(:kc_ent),
        k046: Modifier.from_id!(:kc_lsft),
        k047: Key.from_id!(:kc_z),
        k048: Key.from_id!(:kc_x),
        k049: Key.from_id!(:kc_c),
        k050: Key.from_id!(:kc_v),
        k051: Key.from_id!(:kc_b),
        k052: Key.from_id!(:kc_n),
        k053: Key.from_id!(:kc_m),
        k054: Key.from_id!(:kc_comm),
        k055: Key.from_id!(:kc_dot),
        k056: Key.from_id!(:kc_slsh),
        k057: Modifier.from_id!(:kc_rsft),
        k058: Key.from_id!(:kc_up),
        k059: Modifier.from_id!(:kc_lctl),
        k060: Modifier.from_id!(:kc_lspr),
        k061: Modifier.from_id!(:kc_lalt),
        k062: Key.from_id!(:kc_spc),
        k063: Modifier.from_id!(:kc_ralt),
        k064: Modifier.from_id!(:kc_rspr),
        k065: Modifier.from_id!(:kc_rctl),
        k066: Key.from_id!(:kc_left),
        k067: Key.from_id!(:kc_down),
        k068: Key.from_id!(:kc_rght)
      }
    ]
  end
end
