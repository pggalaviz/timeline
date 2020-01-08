defmodule TimelineWeb.PageControllerTest do
  use TimelineWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Timeline"
  end
end
