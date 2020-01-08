defmodule TimelineWeb.PageController do
  use TimelineWeb, :controller
  alias Timeline.TradeData

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def submit(conn, params) do
    case TradeData.get_data(params) do
      {:ok, data} ->
        conn
        |> put_status(:ok)
        |> json(%{status: 200, data: data})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: 422, message: reason})
    end
  end
end
