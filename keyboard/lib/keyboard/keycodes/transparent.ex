defmodule Keyboard.Keycodes.Transparent do
  defstruct []
end

defimpl Inspect, for: Keyboard.Keycodes.Transparent do
  def inspect(_key, _opts) do
    "%Keyboard.Keycodes.Transparent{}"
  end
end
