defmodule Firmware.Keyboard.Keycode do
  @moduledoc """
  Functions for working with `Keycode` structs.
  """

  @enforce_keys [:id, :type, :code, :description]
  defstruct [:id, :type, :code, :description]

  @keys [
    {0x04, :kc_a, "A"},
    {0x05, :kc_b, "B"},
    {0x06, :kc_c, "C"},
    {0x07, :kc_d, "D"},
    {0x08, :kc_e, "E"},
    {0x09, :kc_f, "F"},
    {0x0A, :kc_g, "G"},
    {0x0B, :kc_h, "H"},
    {0x0C, :kc_i, "I"},
    {0x0D, :kc_j, "J"},
    {0x0E, :kc_k, "K"},
    {0x0F, :kc_l, "L"},
    {0x10, :kc_m, "M"},
    {0x11, :kc_n, "N"},
    {0x12, :kc_o, "O"},
    {0x13, :kc_p, "P"},
    {0x14, :kc_q, "Q"},
    {0x15, :kc_r, "R"},
    {0x16, :kc_s, "S"},
    {0x17, :kc_t, "T"},
    {0x18, :kc_u, "U"},
    {0x19, :kc_v, "V"},
    {0x1A, :kc_w, "W"},
    {0x1B, :kc_x, "X"},
    {0x1C, :kc_y, "Y"},
    {0x1D, :kc_z, "Z"},
    {0x1E, :kc_1, "1"},
    {0x1F, :kc_2, "2"},
    {0x20, :kc_3, "3"},
    {0x21, :kc_4, "4"},
    {0x22, :kc_5, "5"},
    {0x23, :kc_6, "6"},
    {0x24, :kc_7, "7"},
    {0x25, :kc_8, "8"},
    {0x26, :kc_9, "9"},
    {0x27, :kc_0, "0"},
    {0x28, :kc_ent, "Enter"},
    {0x29, :kc_esc, "Escape"},
    {0x2A, :kc_bspc, "Backspace"},
    {0x2B, :kc_tab, "Tab"},
    {0x2C, :kc_spc, "Space"},
    {0x2D, :kc_mins, "Minus"},
    {0x2E, :kc_eql, "Equals"},
    {0x2F, :kc_lbrc, "Left Square Bracket"},
    {0x30, :kc_rbrc, "Right Square Bracket"},
    {0x31, :kc_bsls, "Backslash"},
    {0x33, :kc_scln, "Semicolon"},
    {0x34, :kc_quot, "Single Quote"},
    {0x35, :kc_grv, "Grave"},
    {0x36, :kc_comm, "Comma"},
    {0x37, :kc_dot, "Period"},
    {0x38, :kc_slsh, "Slash"},
    {0x39, :kc_clck, "Caps Lock"},
    {0x3A, :kc_f1, "F1"},
    {0x3B, :kc_f2, "F2"},
    {0x3C, :kc_f3, "F3"},
    {0x3D, :kc_f4, "F4"},
    {0x3E, :kc_f5, "F5"},
    {0x3F, :kc_f6, "F6"},
    {0x40, :kc_f7, "F7"},
    {0x41, :kc_f8, "F8"},
    {0x42, :kc_f9, "F9"},
    {0x43, :kc_f10, "F10"},
    {0x44, :kc_f11, "F11"},
    {0x45, :kc_f12, "F12"},
    {0x46, :kc_pscr, "Print Screen"},
    {0x47, :kc_slck, "Scroll Lock"},
    {0x48, :kc_paus, "Pause"},
    {0x49, :kc_ins, "Insert"},
    {0x4A, :kc_home, "Home"},
    {0x4B, :kc_pgup, "Page Up"},
    {0x4C, :kc_del, "Delete"},
    {0x4D, :kc_end, "End"},
    {0x4E, :kc_pgdn, "Page Down"},
    {0x4F, :kc_rght, "Right Arrow"},
    {0x50, :kc_left, "Left Arrow"},
    {0x51, :kc_down, "Down Arrow"},
    {0x52, :kc_up, "Up Arrow"},
    {0x65, :kc_app, "Application"}
  ]

  @modifiers [
    {0x01, :kc_lctl, "Left Control"},
    {0x02, :kc_lsft, "Left Shift"},
    {0x04, :kc_lalt, "Left Alt"},
    {0x08, :kc_lspr, "Left Super"},
    {0x10, :kc_rctl, "Right Control"},
    {0x20, :kc_rsft, "Right Shift"},
    {0x40, :kc_ralt, "Right Alt"},
    {0x80, :kc_rspr, "Right Super"}
  ]

  @doc """
  Gets a keycode by its ID.

  A keycode ID is an `Atom`, e.g. `:kc_a`. This function returns a keycode
  struct by a given ID.

  ## Examples

      iex> from_id!(:kc_a)
      #Firmware.Keyboard.Keycode<A>

      iex> from_id!(:kc_rsft)
      #Firmware.Keyboard.Keycode<Right Shift>
  """
  def from_id!(id)

  for {code, id, description} <- @keys do
    def from_id!(unquote(id)) do
      struct!(__MODULE__,
        id: unquote(id),
        type: :key,
        code: unquote(code),
        description: unquote(description)
      )
    end
  end

  for {code, id, description} <- @modifiers do
    def from_id!(unquote(id)) do
      struct!(__MODULE__,
        id: unquote(id),
        type: :modifier,
        code: unquote(code),
        description: unquote(description)
      )
    end
  end

  def from_id!(id), do: raise("Invalid Keycode ID: #{id}")
end

defimpl Inspect, for: Firmware.Keyboard.Keycode do
  import Inspect.Algebra

  def inspect(keycode, _opts) do
    concat(["#Firmware.Keyboard.Keycode<", keycode.description, ">"])
  end
end
