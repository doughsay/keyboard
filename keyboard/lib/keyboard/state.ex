defmodule Keyboard.State do
  @moduledoc """
  A struct representing the current state of the keyboard.
  """

  use Bitwise

  alias Keyboard.Keycodes.{Key, Layer, Modifier, None, Transparent}

  defstruct active_layers: [],
            keys: %{},
            layers: [],
            modifiers: %{},
            six_keys: [nil, nil, nil, nil, nil, nil]

  @doc """
  Returns a new state struct initialized with the given keymap.
  """
  def new(keymap) do
    layers =
      keymap
      |> Enum.map(fn layer ->
        %{
          active: false,
          layer: layer
        }
      end)
      |> put_in([Access.at(0), :active], true)
      |> Enum.reverse()

    struct!(__MODULE__, layers: layers)
  end

  @doc """
  Adds a key being pressed.
  """
  def press_key(%__MODULE__{} = state, key) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = find_keycode(state.layers, key)

    state
    |> add_key(key, keycode)
    |> apply_keycode(key, keycode)
  end

  defp find_keycode(layers, key) do
    Enum.find_value(layers, %None{}, fn
      %{active: true, layer: %{^key => %Transparent{}}} -> false
      %{active: true, layer: %{^key => keycode}} -> keycode
      _else -> false
    end)
  end

  defp add_key(state, key, keycode) do
    %{state | keys: Map.put(state.keys, key, keycode)}
  end

  defp apply_keycode(state, key, %Modifier{} = modifier) do
    modifier_used? =
      Enum.any?(state.modifiers, fn
        {_key, ^modifier} -> true
        _ -> false
      end)

    if modifier_used? do
      state
    else
      modifiers = Map.put(state.modifiers, key, modifier)

      %{state | modifiers: modifiers}
    end
  end

  defp apply_keycode(state, key, %Key{} = keycode) do
    keycode_used? =
      Enum.any?(state.six_keys, fn
        nil -> false
        {_, kc} -> kc == keycode
      end)

    if keycode_used? do
      state
    else
      {six_keys, _} =
        Enum.map_reduce(state.six_keys, keycode, fn
          x, nil -> {x, nil}
          nil, kc -> {{key, kc}, nil}
          x, kc -> {x, kc}
        end)

      %{state | six_keys: six_keys}
    end
  end

  defp apply_keycode(state, _key, %Layer{type: :hold} = layer) do
    layers =
      state.layers
      |> Enum.reverse()
      |> put_in([Access.at(layer.layer_id), :active], true)
      |> Enum.reverse()

    %{state | layers: layers}
  end

  defp apply_keycode(state, _key, %None{}) do
    state
  end

  @doc """
  Releases a key being pressed.
  """
  def release_key(%__MODULE__{} = state, key) do
    if !Map.has_key?(state.keys, key), do: raise("Unpressed key released! #{key}")

    {state, keycode} = remove_key(state, key)

    unapply_keycode(state, key, keycode)
  end

  defp remove_key(state, key) do
    %{^key => keycode} = state.keys
    keys = Map.delete(state.keys, key)

    {%{state | keys: keys}, keycode}
  end

  defp unapply_keycode(state, key, %Modifier{} = modifier) do
    modifiers =
      state.modifiers
      |> Enum.filter(fn
        {^key, ^modifier} -> false
        _ -> true
      end)
      |> Map.new()

    %{state | modifiers: modifiers}
  end

  defp unapply_keycode(state, key, %Key{} = keycode) do
    six_keys =
      Enum.map(state.six_keys, fn
        {^key, ^keycode} -> nil
        x -> x
      end)

    %{state | six_keys: six_keys}
  end

  defp unapply_keycode(state, _key, %Layer{type: :hold} = layer) do
    layers =
      state.layers
      |> Enum.reverse()
      |> put_in([Access.at(layer.layer_id), :active], false)
      |> Enum.reverse()

    %{state | layers: layers}
  end

  defp unapply_keycode(state, _key, %None{}) do
    state
  end

  @doc """
  Dump keyboard state to HID report.
  """
  def to_hid_report(%__MODULE__{} = state) do
    modifiers_bitmask =
      Enum.reduce(state.modifiers, 0, fn {_, keycode}, acc ->
        keycode.value ||| acc
      end)

    keycodes =
      Enum.map(state.six_keys, fn
        nil -> 0
        {_, %{value: value}} -> value
      end)

    ([modifiers_bitmask, 0x00] ++ keycodes) |> List.to_string()
  end
end

defimpl Inspect, for: Keyboard.State do
  import Inspect.Algebra

  alias Keyboard.State

  def inspect(state, opts) do
    hid = State.to_hid_report(state)
    concat(["#Keyboard.State<", to_doc(hid, opts), ">"])
  end
end
