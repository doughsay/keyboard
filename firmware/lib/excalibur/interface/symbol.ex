defmodule Excalibur.Interface.Symbol do
  alias AFK.Keycode.{Key, KeyLock, Layer, Modifier, None, Transparent}

  defprotocol Proto do
    def symbol(keycode)
  end

  defimpl Proto, for: Key do
    def symbol(%Key{key: :"1"}), do: "! 1"
    def symbol(%Key{key: :"2"}), do: "@ 2"
    def symbol(%Key{key: :"3"}), do: "# 3"
    def symbol(%Key{key: :"4"}), do: "$ 4"
    def symbol(%Key{key: :"5"}), do: "% 5"
    def symbol(%Key{key: :"6"}), do: "^ 6"
    def symbol(%Key{key: :"7"}), do: "& 7"
    def symbol(%Key{key: :"8"}), do: "* 8"
    def symbol(%Key{key: :"9"}), do: "( 9"
    def symbol(%Key{key: :"0"}), do: ") 0"
    # alternate: "↩" or "⏎" or "⮰"
    def symbol(%Key{key: :enter}), do: "↵"
    def symbol(%Key{key: :escape}), do: "⎋"
    # alternate: "⌫"
    def symbol(%Key{key: :backspace}), do: "⟵"
    def symbol(%Key{key: :tab}), do: "⭾"
    def symbol(%Key{key: :space}), do: " "
    def symbol(%Key{key: :minus}), do: "- _"
    def symbol(%Key{key: :equals}), do: "= +"
    def symbol(%Key{key: :left_square_bracket}), do: "{ ["
    def symbol(%Key{key: :right_square_bracket}), do: "} ]"
    def symbol(%Key{key: :backslash}), do: "| \\"
    def symbol(%Key{key: :semicolon}), do: ": ;"
    def symbol(%Key{key: :single_quote}), do: "\" '"
    def symbol(%Key{key: :grave}), do: "~ `"
    def symbol(%Key{key: :comma}), do: "< ,"
    def symbol(%Key{key: :period}), do: "> ."
    def symbol(%Key{key: :slash}), do: "? /"
    def symbol(%Key{key: :caps_lock}), do: "⇪"
    def symbol(%Key{key: :print_screen}), do: "⎙"
    def symbol(%Key{key: :scroll_lock}), do: "⇳🔒"
    def symbol(%Key{key: :pause}), do: "⎉"
    def symbol(%Key{key: :insert}), do: "⎀"
    # alternate: "↖"
    def symbol(%Key{key: :home}), do: "⤒"
    # alternate: "⇞"
    def symbol(%Key{key: :page_up}), do: "🡑"
    def symbol(%Key{key: :delete}), do: "⌦"
    # alternate: "↘"
    def symbol(%Key{key: :end}), do: "⤓"
    # alternate: "⇟"
    def symbol(%Key{key: :page_down}), do: "🡓"
    def symbol(%Key{key: :right}), do: "→"
    def symbol(%Key{key: :left}), do: "←"
    def symbol(%Key{key: :down}), do: "↓"
    def symbol(%Key{key: :up}), do: "↑"
    def symbol(%Key{key: :application}), do: "▤"
    def symbol(%Key{key: key}), do: key |> to_string() |> String.upcase()
  end

  defimpl Proto, for: KeyLock do
    def symbol(%KeyLock{}), do: "🔐"
  end

  def symbol(keycode), do: Proto.symbol(keycode)

  defimpl Proto, for: Layer do
    def symbol(%Layer{mode: :hold, layer: layer}), do: "ℒ#{layer}"
    def symbol(%Layer{mode: :toggle, layer: layer}), do: "𝒯#{layer}"
    def symbol(%Layer{mode: :default, layer: layer}), do: "𝒟#{layer}"
  end

  defimpl Proto, for: Modifier do
    def symbol(%Modifier{modifier: mod}) when mod in ~w(left_control right_control)a, do: "⌃"
    def symbol(%Modifier{modifier: mod}) when mod in ~w(left_shift right_shift)a, do: "⇧"
    # alternate: "⌥"
    def symbol(%Modifier{modifier: mod}) when mod in ~w(left_alt right_alt)a, do: "⎇"
    # alternate: "❖" or "◆"
    def symbol(%Modifier{modifier: mod}) when mod in ~w(left_super right_super)a, do: "⌘"
  end

  defimpl Proto, for: None do
    def symbol(%None{}), do: "🛇"
  end

  defimpl Proto, for: Transparent do
    def symbol(%Transparent{}), do: "ˇ"
  end
end
