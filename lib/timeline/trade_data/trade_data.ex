defmodule Timeline.TradeData do
  @moduledoc """
  Fetches Data from World Trading Data
  """
  require Logger
  alias Timeline.TradeData.Cache

  @history_url "https://api.worldtradingdata.com/api/v1/history_multi_single_day"
  @actual_url "https://api.worldtradingdata.com/api/v1/stock"
  @api_token "&api_token=pEYXuFI0Ncu29s3lFIab5TrY7ZqQwQK38gAFs0Adr820zR92sJtN57A25tVg"

  def get_data(%{"symbols" => symbols, "date" => date, "amount" => amount} = params) when is_list(symbols) do
    Logger.info("params: #{inspect(params)}")

    parsed_symbols = symbols
      |> Enum.reduce([], fn sym, acc ->
        [sym["name"] | acc]
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.chunk_every(2, 2, :discard)
      |> List.first()
      |> Enum.join(",")


    history_url = @history_url <> "?symbol=#{parsed_symbols}&date=#{date}" <> @api_token
    Logger.info("HISTORY_URL: #{inspect(history_url)}")
    actual_url = @actual_url <> "?symbol=#{parsed_symbols}" <> @api_token
    Logger.info("ACTUAL_URL: #{inspect(actual_url)}")

    with \
      {:ok, %HTTPoison.Response{status_code: 200, body: history_body}} <- HTTPoison.get(history_url),
      {:ok, %HTTPoison.Response{status_code: 200, body: actual_body}} <- HTTPoison.get(actual_url)
    do
      ab = actual_body
        |> Jason.decode!()
        |> _parse_actual()

      history_body
      |> Jason.decode!()
      |> _parse_result(symbols, amount)
      |> _add_actual_price(ab)
    else
      _other ->
        {:error, "An error ocurred fetching data!"}
    end
  end

  def get_data(%{"id" => id}) when is_binary(id) do
    case Cache.get(id) do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "An error ocurred fetching data!"}
    end
  end

  def get_data(_), do: {:error, "Can't process that request."}

  # =================
  # Private Functions
  # =================

  defp _parse_result(%{"data" => data}, symbols, full_amount) do
    data = data
      |> Map.to_list()
      |> Enum.map(fn {name, content} ->
        s = Enum.find(symbols, fn sym ->
          sym["name"] == name
        end)
        amount = Kernel.div((s["percentage"] * full_amount), 100)
        {ci, _} = Float.parse(content["close"])
        total = amount
          |> Kernel./(ci)
          |> Float.round(2)
        Map.merge(content, %{"name" => name, "amount" => amount, "total" => total})
      end)

    {:ok, data}
  end

  defp _parse_result(response, _, _ ) do
    Logger.error("External API error: #{inspect(response)}")
    {:error, "An error ocurred!"}
  end

  defp _parse_actual(%{"data" => data}) do
    data
    |> Enum.map(fn x ->
      name = x["symbol"]
      price = x["price"]
      %{"name" => name, "price" => price}
    end)
  end

  defp _parse_actual(response) do
    Logger.error("External API error: #{inspect(response)}")
    {:error, "An error ocurred!"}
  end

  defp _add_actual_price({:ok, data}, price_data) do
    data = data
      |> Enum.map(fn item ->
        s = Enum.find(price_data, fn x ->
          x["name"] == item["name"]
        end)
        Map.merge(item, %{"actual" => s["price"]})
      end)
    uuid = Cache.add(data)
    {:ok, %{url: uuid, data: data}}
  end

  defp _add_actual_price(_, _ ) do
    {:error, "An error ocurred!"}
  end
end
