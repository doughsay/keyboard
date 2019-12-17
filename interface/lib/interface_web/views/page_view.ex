defmodule InterfaceWeb.PageView do
  use InterfaceWeb, :view

  import Interface.Symbol, only: [symbol: 1]

  alias AFK.Keycode.{Key, Layer, Modifier, None, Transparent}

  @key_width 40
  @space_width 45

  defp layout_to_ui(layout, state) do
    {output, _} =
      Enum.reduce(layout, {[], 0}, fn row, {output, current_y} ->
        {row_output, _} =
          Enum.reduce(row, {[], 0}, fn
            {width, id}, {acc, current_x} ->
              px_width = width * @key_width + (width - 1) * 5
              key = make_key(id, current_x, current_y, px_width, state)
              acc = [key | acc]
              {acc, current_x + width * @space_width}

            id, {acc, current_x} when is_atom(id) ->
              key = make_key(id, current_x, current_y, @key_width, state)
              acc = [key | acc]
              {acc, current_x + @space_width}

            width, {acc, current_x} when is_number(width) ->
              {acc, current_x + width * @space_width}
          end)

        row_output = Enum.reverse(row_output)

        {[row_output | output], current_y + @space_width}
      end)

    Enum.reverse(output)
  end

  defp make_key(id, x, y, width, state) do
    keycode = AFK.State.Keymap.find_keycode(state.keymap, id)
    active? = Map.has_key?(state.keys, id)

    %{id: id, x: x, y: y, width: width, active?: active?, symbol: symbol(keycode)}
  end

  defp all_keycodes do
    keys = AFK.Scancode.keys() |> Enum.map(fn {_, key} -> Key.new(key) end)

    # TODO: num layers?
    layers =
      [0, 1]
      |> Enum.flat_map(fn layer -> [Layer.new(:hold, layer), Layer.new(:toggle, layer), Layer.new(:default, layer)] end)

    modifiers = AFK.Scancode.modifiers() |> Enum.map(fn {_, mod} -> Modifier.new(mod) end)

    keys ++ layers ++ modifiers ++ [None.new(), Transparent.new()]
  end
end
