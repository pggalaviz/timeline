defmodule Timeline.TradeDataTest do
  use ExUnit.Case
  alias Timeline.TradeData

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

  test "Gets data from external API" do
    assert {:ok, data} = TradeData.get_data(@params)
    assert length(data) == 2
    assert List.first(data)["amount"] == 61500
    assert List.first(data)["actual"] != nil
  end
end
