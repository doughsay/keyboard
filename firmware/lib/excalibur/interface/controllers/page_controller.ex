defmodule Excalibur.Interface.PageController do
  use Phoenix.Controller, namespace: Excalibur.Interface

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
