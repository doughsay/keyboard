defmodule Keyboard.Keycodes.Layer do
  @enforce_keys [:type, :layer_id, :description]
  defstruct [:type, :layer_id, :description]

  def new(:hold, layer_id) do
    struct!(__MODULE__,
      type: :hold,
      layer_id: layer_id,
      description: "#{layer_id} While Held"
    )
  end
end

defimpl Inspect, for: Keyboard.Keycodes.Layer do
  import Inspect.Algebra

  def inspect(layer, _opts) do
    concat(["#Keyboard.Keycodes.Layer<", layer.description, ">"])
  end
end
