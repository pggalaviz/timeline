defmodule TimelineWeb.PageController do
  use TimelineWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
