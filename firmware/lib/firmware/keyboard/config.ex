defmodule Firmware.Keyboard.Config do
  @moduledoc """
  Parses and loads various kinds of config strings into keyboard config data
  structures.
  """

  alias Firmware.Keyboard.Keycode
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

  # This is the physical layout of the switches on the keyboard.
  @switch_layout """
                 k001 k002 k003 k004 k005 k006 k007 k008 k009 k010 k011 k012 k013 k014  k015 k016
                 k017 k018 k019 k020 k021 k022 k023 k024 k025 k026 k027 k028 k029 k030  k031 k032
                 k033 k034 k035 k036 k037 k038 k039 k040 k041 k042 k043 k044 k045
                 k046 k047 k048 k049 k050 k051 k052 k053 k054 k055 k056 k057            k058
                 k059 k060 k061                  k062              k063 k064 k065  k066 k067 k068
                 """
                 |> Parser.parse!()

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

  @doc """
  Returns the layout of the physical switches of the keyboard.

  ## Example

      iex> switch_layout()
      [
        [:k001, :k002, :k003, :k004, :k005, :k006, :k007, :k008, :k009, :k010, :k011, :k012, :k013, :k014, :k015, :k016],
        [:k017, :k018, :k019, :k020, :k021, :k022, :k023, :k024, :k025, :k026, :k027, :k028, :k029, :k030, :k031, :k032],
        [:k033, :k034, :k035, :k036, :k037, :k038, :k039, :k040, :k041, :k042, :k043, :k044, :k045],
        [:k046, :k047, :k048, :k049, :k050, :k051, :k052, :k053, :k054, :k055, :k056, :k057, :k058],
        [:k059, :k060, :k061, :k062, :k063, :k064, :k065, :k066, :k067, :k068]
      ]
  """
  def switch_layout, do: @switch_layout

  @doc """
  Returns the name of the current keymap.

  ## Example

      iex> current_keymap_name()
      "default"
  """
  def current_keymap_name,
    do: Application.fetch_env!(:firmware, :current_keymap_file) |> File.read!() |> String.trim()

  @doc """
  Returns the current keymap.

  ## Example

      iex> current_keymap()
      [
        [:kc_esc, :kc_1, :kc_2, :kc_3, :kc_4, :kc_5, :kc_6, :kc_7, :kc_8, :kc_9, :kc_0, :kc_mins, :kc_eql, :kc_bspc, :kc_home, :kc_pgup],
        [:kc_tab, :kc_q, :kc_w, :kc_e, :kc_r, :kc_t, :kc_y, :kc_u, :kc_i, :kc_o, :kc_p, :kc_lbrc, :kc_rbrc, :kc_bsls, :kc_end, :kc_pgdn],
        [:kc_grv, :kc_a, :kc_s, :kc_d, :kc_f, :kc_g, :kc_h, :kc_j, :kc_k, :kc_l, :kc_scln, :kc_quot, :kc_ent],
        [:kc_lsft, :kc_z, :kc_x, :kc_c, :kc_v, :kc_b, :kc_n, :kc_m, :kc_comm, :kc_dot, :kc_slsh, :kc_rsft, :kc_up],
        [:kc_lctl, :kc_lspr, :kc_lalt, :kc_spc, :kc_ralt, :kc_rspr, :kc_rctl, :kc_left, :kc_down, :kc_rght]
      ]
  """
  def current_keymap do
    keymaps_path = Application.fetch_env!(:firmware, :keymaps_path)
    current_keymap = current_keymap_name()

    Path.join(keymaps_path, current_keymap)
    |> File.read!()
    |> Parser.parse!()
  end

  @doc """
  Returns a map of switch IDs to `Firmware.Keyboard.Keycode`s.

  ## Example

      iex> map = switch_to_keycode_map()
      ...> map[:k001]
      #Firmware.Keyboard.Keycode<Escape>
  """
  def switch_to_keycode_map do
    Enum.zip(switch_layout(), current_keymap())
    |> Enum.flat_map(fn {layout_row, keymap_row} ->
      keycodes = Enum.map(keymap_row, &Keycode.from_id!/1)
      Enum.zip(layout_row, keycodes)
    end)
    |> Map.new()
  end
end
