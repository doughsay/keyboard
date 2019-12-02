defimpl Keyboard.State.ApplyKeycode, for: Keyboard.Keycodes.Layer do
  def apply_keycode(layer_keycode, state, key) do
    layers =
      state.layers
      |> Enum.reverse()
      |> put_in([Access.at(layer_keycode.layer_id), :active], true)
      |> put_in([Access.at(layer_keycode.layer_id), :activations, key], layer_keycode)
      |> Enum.reverse()

    %{state | layers: layers}
  end

  def unapply_keycode(layer_keycode, state, key) do
    layer =
      state.layers
      |> Enum.reverse()
      |> Enum.at(layer_keycode.layer_id)
      |> update_in([:activations], fn activations -> Map.delete(activations, key) end)

    layer =
      if layer.activations == %{} do
        %{layer | active: false}
      else
        layer
      end

    layers =
      state.layers
      |> Enum.reverse()
      |> put_in([Access.at(layer_keycode.layer_id)], layer)
      |> Enum.reverse()

    %{state | layers: layers}
  end
end
