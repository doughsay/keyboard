defmodule Excalibur.Interface.PageView do
  use Phoenix.View,
    root: "lib/excalibur/interface/templates",
    namespace: Excalibur.Interface

  use Phoenix.HTML

  import Excalibur.Interface.Symbol, only: [symbol: 1]

  defp dump_keycode(keycode) do
    keycode
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end
