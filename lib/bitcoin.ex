defmodule Bitcoin do

  def create_network_nodes(num_nodes, main_pid) do
    {_, nodes} = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_network_node(main_pid) end) |> Enum.unzip
    nodes 
  end

  def create_network_node(main_pid) do
    FullNode.start_link([]) #neighbor list
    #decide initial state variables
  end

  def set_peers(nodes) do
    for node <- nodes do
      FullNode.add_peers(node, Enum.filter(nodes, fn(x) -> x != node end))
    end
  end
  
end
