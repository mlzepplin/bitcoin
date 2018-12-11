defmodule PubSub do
  use GenServer
  @moduledoc """
  Provides methods for subscribing and publishing to topics.
  """

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def subscribe(topic, pid) do
    :pg2.create(topic)
    case :pg2.get_members(topic) do
      {:error, error} ->
       {:error, error}
      pids ->
        #IO.inspect pids
        unless pid in pids do
          :pg2.join(topic, pid)
          {:ok, :registered}
      else
        {:ok, :already_registered}
      end

      
    end
  end

  def publish(topic, {:transaction, recieved_tx}) do
    case :pg2.get_members(topic) do
      {:error, err} ->
        {:error, err}
      pids ->
        for pid <- pids, do: GenServer.cast(pid, {:tx_reciever,recieved_tx})
        :ok
    end
  end

  def publish(topic, {:block, mined_block}) do
    case :pg2.get_members(topic) do
      {:error, err} ->
        {:error, err}
      pids ->
        for pid <- pids, do: GenServer.cast(pid, {:block, mined_block})
        :ok
    end
  end


end