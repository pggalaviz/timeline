defmodule Timeline.TradeDataTest do
  use ExUnit.Case
  alias Timeline.TradeData
  alias Timeline.TradeData.Cache

  @params %{
    "symbols" => [
      %{
        "name" => "TWTR",
        "percentage" => 50
      },
      %{
        "name" => "GOOG",
        "percentage" => 50
      },
      %{
        "name" => "VOD.L",
        "percentage" => 50
      }
    ],
    "date" => "2015-01-08",
    "amount" => 123000
  }

  test "Gets data from external API and caches it" do
    assert {:ok, %{url: url, data: data}} = TradeData.get_data(@params)
    assert length(data) == 2
    assert List.first(data)["amount"] == 61500
    assert List.first(data)["actual"] != nil

    assert {:ok, cached_data} = Cache.get(url)
    assert cached_data == data
  end
end
