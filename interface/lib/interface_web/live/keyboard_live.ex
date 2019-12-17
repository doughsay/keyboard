defmodule InterfaceWeb.KeyboardLive do
  use Phoenix.LiveView

  alias Phoenix.PubSub

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
    Phoenix.View.render(InterfaceWeb.PageView, "keyboard.html", assigns)
  end

  def mount(_args, socket) do
    # keymap = Interface.Agent.keymap()
    state = Interface.Agent.keyboard_server().get_state()

    socket =
      socket
      |> assign(:keyboard_layout, @keyboard_layout)
      |> assign(:state, state)

    if connected?(socket) do
      PubSub.subscribe(Interface.PubSub, "keyboard")
    end

    {:ok, socket}
  end

  def handle_info({:state_changed, state}, socket) do
    {:noreply, assign(socket, :state, state)}
  end
end
