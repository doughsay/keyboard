defmodule Excalibur.Interface.KeyboardLive do
  use Phoenix.LiveView

  alias AFK.Keycode.{Key, KeyLock, Layer, Modifier, None, Transparent}
  alias Phoenix.PubSub

  import Excalibur.Interface.Symbol, only: [symbol: 1]

  @key_width 40
  @space_width 45

  @keyboard_layout [
    [
      :k001,
      :k002,
      :k003,
      :k004,
      :k005,
      :k006,
      :k007,
      :k008,
      :k009,
      :k010,
      :k011,
      :k012,
      :k013,
      {2, :k014},
      0.25,
      :k015,
      :k016
    ],
    [
      {1.5, :k017},
      :k018,
      :k019,
      :k020,
      :k021,
      :k022,
      :k023,
      :k024,
      :k025,
      :k026,
      :k027,
      :k028,
      :k029,
      {1.5, :k030},
      0.25,
      :k031,
      :k032
    ],
    [
      {1.75, :k033},
      :k034,
      :k035,
      :k036,
      :k037,
      :k038,
      :k039,
      :k040,
      :k041,
      :k042,
      :k043,
      :k044,
      {2.25, :k045}
    ],
    [
      {2.25, :k046},
      :k047,
      :k048,
      :k049,
      :k050,
      :k051,
      :k052,
      :k053,
      :k054,
      :k055,
      :k056,
      {2.75, :k057},
      0.25,
      :k058
    ],
    [
      {1.25, :k059},
      {1.25, :k060},
      {1.25, :k061},
      {6.25, :k062},
      {1.25, :k063},
      {1.25, :k064},
      {1.25, :k065},
      0.5,
      :k066,
      :k067,
      :k068
    ]
  ]

  def render(assigns) do
    Phoenix.View.render(Excalibur.Interface.PageView, "keyboard.html", assigns)
  end

  def mount(_args, socket) do
    state = Excalibur.Firmware.KeyboardServer.get_state()
    keymap = Excalibur.Firmware.KeyboardServer.get_keymap()
    socket = update_socket(socket, state, keymap)

    if connected?(socket) do
      PubSub.subscribe(Excalibur.PubSub, "keyboard")
    end

    {:ok, socket}
  end

  defp update_socket(socket, state, keymap) do
    keycodes = all_keycodes(Enum.count(keymap))

    ui_state =
      state
      |> make_key()
      |> make_ui_state()

    layers =
      keymap
      |> Enum.with_index()
      |> Map.new(fn {_layer, index} ->
        {"Layer #{index}", index}
      end)

    current_layer = 0
    keymap_edits = keymap

    keymap_ui =
      keymap_edits
      |> Enum.at(current_layer)
      |> make_edit_key()
      |> make_ui_state()

    socket
    |> assign(:ui_state, ui_state)
    |> assign(:keycodes, keycodes)
    |> assign(:layers, layers)
    |> assign(:current_layer, current_layer)
    |> assign(:keymap_edits, keymap_edits)
    |> assign(:keymap_edits_ui_state, keymap_ui)
  end

  def handle_event("select_layer", %{"form" => %{"layer" => layer}}, socket) do
    current_layer = String.to_integer(layer)

    keymap_ui =
      socket.assigns.keymap_edits
      |> Enum.at(current_layer)
      |> make_edit_key()
      |> make_ui_state()

    socket =
      socket
      |> assign(:current_layer, current_layer)
      |> assign(:keymap_edits_ui_state, keymap_ui)

    {:noreply, socket}
  end

  def handle_event("set_keycode", %{"key" => key_string, "keycode" => encoded_keycode}, socket) do
    key = key_string |> String.to_existing_atom()
    keycode = encoded_keycode |> Base.decode64!() |> :erlang.binary_to_term()

    current_layer = socket.assigns.current_layer
    keymap_edits = put_in(socket.assigns.keymap_edits, [Access.at(current_layer), key], keycode)

    keymap_ui =
      keymap_edits
      |> Enum.at(current_layer)
      |> make_edit_key()
      |> make_ui_state()

    socket =
      socket
      |> assign(:keymap_edits, keymap_edits)
      |> assign(:keymap_edits_ui_state, keymap_ui)

    {:noreply, socket}
  end

  def handle_event("save_edits", _params, socket) do
    Excalibur.Firmware.KeyboardServer.update_keymap(socket.assigns.keymap_edits)

    {:noreply, update_socket(socket, Excalibur.Firmware.KeyboardServer.get_state(), socket.assigns.keymap_edits)}
  end

  def handle_info({:state_changed, state}, socket) do
    ui_state = state |> make_key() |> make_ui_state()
    {:noreply, assign(socket, :ui_state, ui_state)}
  end

  defp make_ui_state(fun) do
    {output, _} =
      Enum.reduce(@keyboard_layout, {[], 0}, fn row, {output, current_y} ->
        {row_output, _} =
          Enum.reduce(row, {[], 0}, fn
            {width, id}, {acc, current_x} ->
              px_width = width * @key_width + (width - 1) * 5
              key = fun.(id, current_x, current_y, px_width)
              acc = [key | acc]
              {acc, current_x + width * @space_width}

            id, {acc, current_x} when is_atom(id) ->
              key = fun.(id, current_x, current_y, @key_width)
              acc = [key | acc]
              {acc, current_x + @space_width}

            width, {acc, current_x} when is_number(width) ->
              {acc, current_x + width * @space_width}
          end)

        row_output = Enum.reverse(row_output)

        {[row_output | output], current_y + @space_width}
      end)

    Enum.reverse(output)
  end

  defp make_key(state) do
    fn id, x, y, width ->
      keycode = AFK.State.Keymap.find_keycode(state.keymap, id)

      {active?, keycode} =
        case state.keys[id] do
          nil -> {false, keycode}
          keycode -> {true, keycode}
        end

      %{id: id, x: x, y: y, width: width, active?: active?, symbol: symbol(keycode)}
    end
  end

  defp make_edit_key(keymap) do
    fn id, x, y, width ->
      keycode = keymap[id]

      %{id: id, x: x, y: y, width: width, symbol: symbol(keycode)}
    end
  end

  defp all_keycodes(n) do
    keys = AFK.Scancode.keys() |> Enum.map(fn {_, key} -> Key.new(key) end)

    layers =
      case n do
        0 ->
          []

        n ->
          0..(n - 1)
          |> Enum.flat_map(fn layer ->
            [Layer.new(:hold, layer), Layer.new(:toggle, layer), Layer.new(:default, layer)]
          end)
      end

    modifiers = AFK.Scancode.modifiers() |> Enum.map(fn {_, mod} -> Modifier.new(mod) end)

    keys ++ layers ++ modifiers ++ [None.new(), Transparent.new(), KeyLock.new()]
  end
end
