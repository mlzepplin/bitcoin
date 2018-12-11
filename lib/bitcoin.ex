defmodule Bitcoin do

  def create_network_nodes(num_nodes) do
    nodes = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_network_node() end) 
     
  end

  #State { public_key, private_key, balance, num_blocks, block_chain, transaction_buffer, input_pool }
  def create_network_node() do
    
    {pub_key, priv_key} = Signature.create_keypair()
    pid = FullNode.start_link({pub_key, priv_key, 0.0, 0, [], [], %{}}) #neighbor list
    PubSub.subscribe("bitcoin_transactions", pid)
    PubSub.subscribe("mined_blocks", pid)
    pid

  end

  # def set_peers(nodes) do
  #   for node <- nodes do
  #     FullNode.add_peers(node, Enum.filter(nodes, fn(x) -> x != node end))
  #   end
  # end
  
end
