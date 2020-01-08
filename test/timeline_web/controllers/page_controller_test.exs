defmodule TimelineWeb.PageControllerTest do
  use TimelineWeb.ConnCase

  @params %{
    "symbols" => [
      %{
        "name" => "TWTR",
        "percentage" => 50
      },
      %{
        "name" => "GOOG",
        "percentage" => 50
      }
    ],
    "date" => "2015-01-08",
    "amount" => 123000
  }

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Timeline"
  end

  test "POST /api", %{conn: conn} do
    conn = post(conn, "/api", @params)
    assert %{"data" => data} = json_response(conn, 200)
    assert Kernel.length(data["data"]) == 2
  end
end
