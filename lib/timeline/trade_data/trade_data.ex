defmodule Timeline.TradeData do
  @moduledoc """
  Fetches Data from World Trading Data
  """
  require Logger
  @history_url "https://api.worldtradingdata.com/api/v1/history_multi_single_day"
  @api_token "&api_token=pEYXuFI0Ncu29s3lFIab5TrY7ZqQwQK38gAFs0Adr820zR92sJtN57A25tVg"

  def get_data(%{"symbols" => symbols, "date" => date, "amount" => amount} = params) when is_list(symbols) do
    Logger.info("params: #{inspect(params)}")

    parsed_symbols = symbols
      |> Enum.reduce([], fn sym, acc ->
        [sym["name"] | acc]
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.join(",")

    history_url = @history_url <> "?symbol=#{parsed_symbols}&date=#{date}" <> @api_token
    Logger.info("HISTORY_URL: #{inspect(history_url)}")

    case HTTPoison.get(history_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> _parse_result(symbols, amount)

      _other ->
        {:error, "An error ocurred!"}
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
end
