defmodule Keyboard.State do
  @moduledoc """
  A struct representing the current state of the keyboard.
  """

  use Bitwise

  alias Keyboard.Keycode

  defstruct keymap: [],
            keys: %{},
            modifiers: %{},
            six_keys: [nil, nil, nil, nil, nil, nil]

  @doc """
  Returns a new state struct initialized with the given keymap.
  """
  def new(keymap) do
    struct!(__MODULE__, keymap: keymap |> Enum.with_index() |> ZipperList.from_list())
  end

  @doc """
  Adds a key being pressed.
  """
  def press_key(%__MODULE__{} = state, key) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    {%{^key => keycode}, _} = state.keymap.cursor

    state
    |> add_key(key, keycode)
    |> apply_keycode(key, keycode)
  end

  defp add_key(state, key, keycode) do
    %{state | keys: Map.put(state.keys, key, keycode)}
  end

  defp apply_keycode(state, key, %Keycode{type: :modifier} = keycode) do
    keycode_used? =
      Enum.any?(state.modifiers, fn
        {_key, ^keycode} -> true
        _ -> false
      end)

    if keycode_used? do
      state
    else
      modifiers = Map.put(state.modifiers, key, keycode)

      %{state | modifiers: modifiers}
    end
  end

  defp apply_keycode(state, key, %Keycode{type: :key} = keycode) do
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

  defp apply_keycode(state, _key, %Keycode{id: :mo} = keycode) do
    keymap =
      state.keymap
      |> ZipperList.cursor_start()
      |> Enum.find(fn %{cursor: {_, idx}} -> idx == keycode.code end)

    %{state | keymap: keymap}
  end

  defp apply_keycode(state, _key, %Keycode{id: :none}) do
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

  defp unapply_keycode(state, key, %Keycode{type: :modifier} = keycode) do
    modifiers =
      state.modifiers
      |> Enum.filter(fn
        {^key, ^keycode} -> false
        _ -> true
      end)
      |> Map.new()

    %{state | modifiers: modifiers}
  end

  defp unapply_keycode(state, key, %Keycode{type: :key} = keycode) do
    six_keys =
      Enum.map(state.six_keys, fn
        {^key, ^keycode} -> nil
        x -> x
      end)

    %{state | six_keys: six_keys}
  end

  defp unapply_keycode(state, _key, %Keycode{id: :mo}) do
    keymap = ZipperList.cursor_start(state.keymap)
    %{state | keymap: keymap}
  end

  defp unapply_keycode(state, _key, %Keycode{id: :none}) do
    state
  end

  @doc """
  Dump keyboard state to HID report.
  """
  def to_hid_report(%__MODULE__{} = state) do
    modifiers_bitmask =
      Enum.reduce(state.modifiers, 0, fn {_, keycode}, acc ->
        keycode.code ||| acc
      end)

    keycodes =
      Enum.map(state.six_keys, fn
        nil -> 0
        {_, %{code: code}} -> code
      end)

    ([modifiers_bitmask, 0x00] ++ keycodes) |> List.to_string()
  end
end

defimpl Inspect, for: Keyboard.State do
  import Inspect.Algebra

  def inspect(state, opts) do
    list =
      for attr <- [:keys, :modifiers, :six_keys] do
        {attr, Map.get(state, attr)}
      end

    container_doc("#Keyboard.State<", list, ">", opts, fn
      {field, value}, opts -> concat("#{field}: ", to_doc(value, opts))
    end)
  end
end
