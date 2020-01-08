defmodule Timeline.TradeData.Cache do
  @moduledoc """
  Caches a stock request.
  """
  use GenServer
  require Logger
  alias Timeline.TradeData.UUID

  @table :stock

  # ==========
  # Client API
  # ==========

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add(data) do
    uuid = UUID.generate()
    :ets.insert(@table, {uuid, data})
    uuid
  end

  def get(uuid) do
    case :ets.lookup(@table, uuid) do
      [{^uuid, data}] -> {:ok, data}
      _ -> {:error, :not_found}
    end
  end

  # ================
  # Server Callbacks
  # ================

  @impl GenServer
  def init(_opts) do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end
end
