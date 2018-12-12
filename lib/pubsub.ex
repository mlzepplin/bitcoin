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
        unless pid in pids do
          :pg2.join(topic, pid)
          {:ok, :registered}
      else
        {:ok, :already_registered}
      end

      
    end
  end

  #broadcast transactions to all nodes. 
  def publish(topic, {:transaction, recieved_tx, sender_pid}) do
    case :pg2.get_members(topic) do
      {:error, err} ->
        {:error, err}
      pids ->
        miner = Enum.random(pids)
        for pid <- pids do
          if (pid != sender_pid) do
            block_size_reached = GenServer.call(pid, {:tx_receiver,recieved_tx})
            if (block_size_reached && pid==miner) do
              FullNode.mine(pid)
            else
              #No mining
            end
          end
        end
        :ok
    end
  end

  def publish(topic, {:block, mined_block, sender_pid}) do
    case :pg2.get_members(topic) do
      {:error, err} ->
        {:error, err}
      pids ->
        for pid <- pids do
            GenServer.cast(pid, {:block_receiver, mined_block})
         
        end
        :ok
    end
  end


end