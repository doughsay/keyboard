defmodule InterfaceWeb.PageView do
  use InterfaceWeb, :view

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
    # layer = List.first(keymap) || %{}
    # keycode = Map.get(layer, id, %Keycodes.None{})
    active? = Map.has_key?(state.keys, id)

    %{id: id, x: x, y: y, width: width, active?: active?}
  end

  # defp symbol(%Keycodes.None{}), do: "🛇"
  # defp symbol(%{id: :escape}), do: "⎋"
  # defp symbol(%{id: :minus}), do: "- _"
  # defp symbol(%{id: :equals}), do: "= +"
  # defp symbol(%{id: :backspace}), do: "⟵"
  # defp symbol(%{id: :page_up}), do: "⇞"
  # defp symbol(%{id: :page_down}), do: "⇟"
  # defp symbol(%{id: :home}), do: "↖"
  # defp symbol(%{id: :end}), do: "↘"
  # defp symbol(%{id: :tab}), do: "↹"

  # defp symbol(%{id: :up}), do: "↑"
  # defp symbol(%{id: :down}), do: "↓"
  # defp symbol(%{id: :left}), do: "←"
  # defp symbol(%{id: :right}), do: "→"

  # defp symbol(%{id: :"1"}), do: "! 1"
  # defp symbol(%{id: :"2"}), do: "@ 2"
  # defp symbol(%{id: :"3"}), do: "# 3"
  # defp symbol(%{id: :"4"}), do: "$ 4"
  # defp symbol(%{id: :"5"}), do: "% 5"
  # defp symbol(%{id: :"6"}), do: "^ 6"
  # defp symbol(%{id: :"7"}), do: "& 7"
  # defp symbol(%{id: :"8"}), do: "* 8"
  # defp symbol(%{id: :"9"}), do: "( 9"
  # defp symbol(%{id: :"0"}), do: ") 0"

  # defp symbol(%{id: :left_square_bracket}), do: "{ ["
  # defp symbol(%{id: :right_square_bracket}), do: "} ]"
  # defp symbol(%{id: :backslash}), do: "| \\"
  # defp symbol(%{id: :grave}), do: "~ `"
  # defp symbol(%{id: :semicolon}), do: ": ;"
  # defp symbol(%{id: :single_quote}), do: "\" '"

  # defp symbol(%{id: :enter}), do: "↩"
  # defp symbol(%{id: :space}), do: ""

  # defp symbol(%{id: :left_shift}), do: "⇧"
  # defp symbol(%{id: :right_shift}), do: "⇧"
  # defp symbol(%{id: :left_control}), do: "⌃"
  # defp symbol(%{id: :right_control}), do: "⌃"
  # defp symbol(%{id: :left_alt}), do: "⎇"
  # defp symbol(%{id: :right_alt}), do: "⎇"
  # defp symbol(%{id: :left_super}), do: "◆"
  # defp symbol(%{id: :right_super}), do: "◆"

  # defp symbol(%{id: :comma}), do: "< ,"
  # defp symbol(%{id: :period}), do: "> ."
  # defp symbol(%{id: :slash}), do: "? /"

  # defp symbol(%{id: id}) do
  #   id |> to_string() |> String.upcase()
  # end

  # defp symbol(_), do: "??"
end
