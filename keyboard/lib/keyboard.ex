defmodule Keyboard do
  @moduledoc """
  Keyboard related functions, including keymaps, layouts and keycodes.
  """

  alias __MODULE__.Config

  defdelegate row_pins, to: Config
  defdelegate col_pins, to: Config
  defdelegate matrix_layout, to: Config
  defdelegate switch_to_keycode_map, to: Config
end
