defmodule PubSub do
  @moduledoc """
  Provides methods for subscribing and publishing to topics.
  """

  def subscribe(topic, pid) do
    :pg2.create(topic)
    case :pg2.get_members(topic) do
      {:error, error} ->
       {:error, error}
      pids ->
        IO.inspect pids
        unless pid in pids do
          :pg2.join(topic, pid)
          {:ok, :registered}
      else
        {:ok, :already_registered}
      end
    end
  end

  def publish(topic, msg) do
    case :pg2.get_members(topic) do
      {:error, err} ->
        {:error, err}
      pids ->
        for pid <- pids, do: send(pid, msg)
        :ok
    end
  end


end