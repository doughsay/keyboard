defmodule InterfaceWeb.PageView do
  use InterfaceWeb, :view

  @key_width 40
  @space_width 45

  defp layout_to_ui(layout, active_keys) do
    {output, _} = Enum.reduce(layout, {[], 0}, fn row, {output, current_y} ->
      {row_output, _} = Enum.reduce(row, {[], 0}, fn
        {width, id}, {acc, current_x} ->
          px_width = (width * @key_width) + ((width - 1) * 5)
          active? = Map.has_key?(active_keys, id)
          key = %{id: id, x: current_x, y: current_y, width: px_width, active?: active?}
          acc = [key | acc]
          {acc, current_x + (width * @space_width)}

        id, {acc, current_x} when is_atom(id) ->
          active? = Map.has_key?(active_keys, id)
          key = %{id: id, x: current_x, y: current_y, width: @key_width, active?: active?}
          acc = [key | acc]
          {acc, current_x + @space_width}

        width, {acc, current_x} when is_number(width) ->
          {acc, current_x + (width * @space_width)}
      end)

      row_output = Enum.reverse(row_output)

      {[row_output | output], current_y + @space_width}
    end)

    Enum.reverse(output)
  end
end
