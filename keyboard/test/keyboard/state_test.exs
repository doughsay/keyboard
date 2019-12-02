defmodule Keyboard.StateTest do
  use ExUnit.Case
  use Bitwise

  doctest Keyboard.State, import: true

  alias Keyboard.State
  alias Keyboard.Keycodes.{Key, Modifier, Layer, None, Transparent}

  @keymap [
    # Layer 0
    %{
      k001: Modifier.from_id!(:kc_lctl),
      k002: Modifier.from_id!(:kc_lsft),
      k003: Layer.new(:hold, 1),
      k004: Key.from_id!(:kc_a),
      k005: Key.from_id!(:kc_s),
      k006: Key.from_id!(:kc_a)
    },
    # Layer 1
    %{
      k001: Key.from_id!(:kc_z),
      k002: Modifier.from_id!(:kc_lctl),
      k003: %None{},
      k004: %None{},
      k005: %Transparent{},
      k006: Layer.new(:hold, 2)
    },
    # Layer 2
    %{
      k001: Layer.new(:hold, 1),
      k002: %Transparent{},
      k003: %Transparent{},
      k004: Key.from_id!(:kc_x),
      k005: %Transparent{},
      k006: %None{}
    },
    # Layer 3
    %{
      k001: %None{},
      k002: %None{},
      k003: %None{},
      k004: %None{},
      k005: %None{},
      k006: %None{}
    }
  ]

  @lctl 1
  @lsft 2
  @a 4
  @s 22
  @x 27
  @z 29

  describe "new/1" do
    test "initializes a new state struct with the given keymap" do
      assert %State{} = state = State.new(@keymap)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end
  end

  describe "&press_key/2 & &release_key/2" do
    setup do
      {:ok, [state: State.new(@keymap)]}
    end

    test "raises if same physical key is pressed twice", %{state: state} do
      state = State.press_key(state, :k001)

      assert_raise RuntimeError, fn ->
        State.press_key(state, :k001)
      end
    end

    test "raises if same physical key is release twice", %{state: state} do
      state =
        state
        |> State.press_key(:k001)
        |> State.release_key(:k001)

      assert_raise RuntimeError, fn ->
        State.release_key(state, :k001)
      end
    end

    test "press and release both modifiers on layer 0", %{state: state} do
      state = State.press_key(state, :k001)
      assert <<@lctl, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      state = State.press_key(state, :k002)
      both_modifiers = @lctl ||| @lsft
      assert <<^both_modifiers, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      state = State.release_key(state, :k001)
      assert <<@lsft, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      state = State.release_key(state, :k002)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "press and release a on layer 0", %{state: state} do
      state = State.press_key(state, :k004)
      assert <<0, 0, @a, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      state = State.release_key(state, :k004)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "activate layer 1 then press z", %{state: state} do
      state = State.press_key(state, :k003)
      # shifting layers has no effect on HID state
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      state = State.press_key(state, :k001)
      assert <<0, 0, @z, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # releasing the layer activation key doesn't release z
      state = State.release_key(state, :k003)
      assert <<0, 0, @z, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      state = State.release_key(state, :k001)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "activate layer 1 then release layer 1 then press a", %{state: state} do
      state =
        state
        |> State.press_key(:k003)
        |> State.release_key(:k003)
        |> State.press_key(:k004)

      assert <<0, 0, @a, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "activate layer 1 then press none", %{state: state} do
      state = State.press_key(state, :k003)
      state = State.press_key(state, :k004)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "activate layer 1 then press transparent, which falls down to s", %{state: state} do
      state = State.press_key(state, :k003)
      state = State.press_key(state, :k005)
      assert <<0, 0, @s, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "pressing the same logical key using two different physical keys", %{state: state} do
      state =
        state
        |> State.press_key(:k004)
        |> State.press_key(:k006)

      # a is only pressed once
      assert <<0, 0, @a, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # releasing the second instance of a doesn't release it
      state = State.release_key(state, :k006)
      assert <<0, 0, @a, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # releasing the original instance of a releases it
      state = State.release_key(state, :k004)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "pressing the same logical modifier using two different physical keys", %{state: state} do
      state =
        state
        # left control
        |> State.press_key(:k001)
        # activate layer 1 while held
        |> State.press_key(:k003)
        # left control again
        |> State.press_key(:k002)

      # left control is only pressed once
      assert <<@lctl, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # releasing the second instance of left control doesn't release it
      state = State.release_key(state, :k002)
      assert <<@lctl, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # releasing the original instance of a releases it
      state = State.release_key(state, :k001)
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end

    test "activating layer 1 using two different physical keys", %{state: state} do
      state =
        state
        # activate layer 1 while held
        |> State.press_key(:k003)
        # activate layer 2 while held
        |> State.press_key(:k006)
        # activate layer 1 while held again
        |> State.press_key(:k001)

      # no keys have been pressed other than layer activators
      assert <<0, 0, 0, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # press x on layer 2
      state = State.press_key(state, :k004)
      assert <<0, 0, @x, 0, 0, 0, 0, 0>> = State.to_hid_report(state)

      # releasing second layer 1 activation key still leaves layer 1 active
      state =
        state
        # release layer 1 second activation
        |> State.release_key(:k001)
        # this press should now be a left control (because layer 1 should still
        # be active and this key is transparent in layer 2)
        |> State.press_key(:k002)

      assert <<@lctl, 0, @x, 0, 0, 0, 0, 0>> = State.to_hid_report(state)
    end
  end
end
