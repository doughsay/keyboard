defmodule InterfaceWeb.PageView do
  use InterfaceWeb, :view

  import Interface.Symbol, only: [symbol: 1]

  defp dump_keycode(keycode) do
    keycode
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end
