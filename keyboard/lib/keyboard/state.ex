defmodule Keyboard.State do
  @moduledoc """
  A struct representing the current state of the keyboard.
  """

  use Bitwise

  alias Keyboard.State.ApplyKeycode
  alias Keyboard.Keycodes.{None, Transparent}

  defstruct keys: %{},
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
          activations: %{},
          layer: layer
        }
      end)
      |> put_in([Access.at(0), :active], true)
      |> put_in([Access.at(0), :activations, :default], true)
      |> Enum.reverse()

    struct!(__MODULE__, layers: layers)
  end

  @doc """
  Adds a key being pressed.
  """
  def press_key(%__MODULE__{} = state, key) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = find_keycode(state.layers, key)
    state = %{state | keys: Map.put(state.keys, key, keycode)}

    ApplyKeycode.apply_keycode(keycode, state, key)
  end

  defp find_keycode(layers, key) do
    Enum.find_value(layers, %None{}, fn
      %{active: true, layer: %{^key => %Transparent{}}} -> false
      %{active: true, layer: %{^key => keycode}} -> keycode
      _else -> false
    end)
  end

  @doc """
  Releases a key being pressed.
  """
  def release_key(%__MODULE__{} = state, key) do
    if !Map.has_key?(state.keys, key), do: raise("Unpressed key released! #{key}")

    %{^key => keycode} = state.keys
    keys = Map.delete(state.keys, key)
    state = %{state | keys: keys}

    ApplyKeycode.unapply_keycode(keycode, state, key)
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
