defmodule OpenBookWeb.PageControllerTest do
  use OpenBookWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Stay fit with close friends"
  end
end
