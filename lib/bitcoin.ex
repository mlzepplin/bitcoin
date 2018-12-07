defmodule Bitcoin do

  def create_network_nodes(num_nodes, main_pid) do
    nodes = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_network_node(main_pid) end) 
     
  end

  #State { public_key, private_key, balance, num_blocks, block_chain, transaction_buffer, input_pool }
  def create_network_node(main_pid) do
    
    {pub_key, priv_key} = Signature.create_keypair()
    pid = FullNode.start_up({pub_key, priv_key, 0.0, 0, [], [], %{}}) #neighbor list
    PubSub.subscribe("bitcoin_transactions", pid)
    pid

  end

  def set_peers(nodes) do
    for node <- nodes do
      FullNode.add_peers(node, Enum.filter(nodes, fn(x) -> x != node end))
    end
  end
  
end
