defmodule Excalibur.Interface.PageControllerTest do
  use Excalibur.Interface.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Keyboard"
  end
end
