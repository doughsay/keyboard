defmodule Keyboard.Keycodes.None do
  defstruct []
end

defimpl Inspect, for: Keyboard.Keycodes.None do
  def inspect(_key, _opts) do
    "%Keyboard.Keycodes.None{}"
  end
end
