defmodule Keyboard.StateTest do
  use ExUnit.Case
  doctest Keyboard.State, import: true

  alias Keyboard.{Keycode, State}

  @keymap [
    %{
      k001: Keycode.none(),
      k002: Keycode.from_id!(:kc_lsft),
      k003: Keycode.special(:mo, 1),
      k004: Keycode.from_id!(:kc_a),
      k005: Keycode.from_id!(:kc_s),
      k006: Keycode.from_id!(:kc_d)
    },
    %{
      k001: Keycode.from_id!(:kc_z),
      k002: Keycode.from_id!(:kc_x),
      k003: Keycode.none(),
      k004: Keycode.from_id!(:kc_v),
      k005: Keycode.from_id!(:kc_b),
      k006: Keycode.from_id!(:kc_n)
    }
  ]

  describe "new/1" do
    test "initializes a new state struct with the given keymap" do
      assert %State{} = State.new(@keymap)
    end
  end

  describe "&press_key/2" do
    setup do
      {:ok, [state: State.new(@keymap)]}
    end

    test "adds an active key to the keyboard state", %{state: state} do
      assert %State{} = state = State.press_key(state, :k001)
      assert Map.has_key?(state.keys, :k001)
    end

    test "raises if given a key that is already active", %{state: state} do
      state = State.press_key(state, :k001)

      assert_raise RuntimeError, fn ->
        State.press_key(state, :k001)
      end
    end

    test "if the key corresponds to a modifier, adds key to modifiers", %{state: state} do
      assert %State{} = state = State.press_key(state, :k001)
      assert Map.has_key?(state.modifiers, :k001)
    end

    test "if the key corresponds to a regular key, adds key to six_keys", %{state: state} do
      assert %State{} = state = State.press_key(state, :k004)
      assert [{:k004, keycode}, _, _, _, _, _] = state.six_keys
    end
  end
end
