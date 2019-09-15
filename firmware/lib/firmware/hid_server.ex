defmodule Firmware.HIDServer do
  use GenServer

  alias Firmware.MatrixServer

  @device "/dev/hidg0"

  @keys %{
    a: 0x04,
    b: 0x05,
    c: 0x06,
    d: 0x07,
    e: 0x08,
    f: 0x09,
    g: 0x0A,
    h: 0x0B,
    i: 0x0C,
    j: 0x0D,
    k: 0x0E,
    l: 0x0F,
    m: 0x10,
    n: 0x11,
    o: 0x12,
    p: 0x13,
    q: 0x14,
    r: 0x15,
    s: 0x16,
    t: 0x17,
    u: 0x18,
    v: 0x19,
    w: 0x1A,
    x: 0x1B,
    y: 0x1C,
    z: 0x1D,
    one: 0x1E,
    two: 0x1F,
    three: 0x20,
    four: 0x21,
    five: 0x22,
    six: 0x23,
    seven: 0x24,
    eight: 0x25,
    nine: 0x26,
    zero: 0x27,
    enter: 0x28,
    escape: 0x29,
    backspace: 0x2A,
    tab: 0x2B,
    space: 0x2C,
    minus: 0x2D,
    equals: 0x2E,
    left_square_bracket: 0x2F,
    right_square_bracket: 0x30,
    backslash: 0x31,
    non_us_hash: 0x32,
    semicolon: 0x33,
    single_quote: 0x34,
    backtick: 0x35,
    comma: 0x36,
    period: 0x37,
    forward_slash: 0x38,
    caps_lock: 0x39,
    f1: 0x3A,
    f2: 0x3B,
    f3: 0x3C,
    f4: 0x3D,
    f5: 0x3E,
    f6: 0x3F,
    f7: 0x40,
    f8: 0x41,
    f9: 0x42,
    f10: 0x43,
    f11: 0x44,
    f12: 0x45,
    print_screen: 0x46,
    scroll_lock: 0x47,
    pause: 0x48,
    insert: 0x49,
    home: 0x4A,
    page_up: 0x4B,
    delete: 0x4C,
    end: 0x4D,
    page_down: 0x4E,
    right: 0x4F,
    left: 0x50,
    down: 0x51,
    up: 0x52,
    # snip
    menu: 0x65
  }

  @modifiers %{
    left_control: 0x01,
    left_shift: 0x02,
    left_alt: 0x04,
    left_super: 0x08,
    right_control: 0x10,
    right_shift: 0x20,
    right_alt: 0x40,
    # untested:
    right_super: 0x80
  }

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, %{device: @device})
  end

  # Server

  @impl true
  def init(%{device: device}) do
    {:ok, file} = File.open(device, [:write])
    {:ok, _matrix} = MatrixServer.start_link(self())

    {:ok, %{hid_file: file}}
  end

  @impl true
  def handle_info({:matrix_changed, _matrix} = event, state) do
    IO.inspect(event)
    {:noreply, state}
  end
end
