num_args = length(System.argv)

num_nodes = String.to_integer(List.first(System.argv))

#simple termination criteria
time_to_run = String.to_integer(List.last(System.argv))


nodes = Util.create_network_nodes(num_nodes)
IO.inspect nodes

init_coins = [
    %{txoid: "input:0", amount: 100.00},
    %{txoid: "input:1", amount: 40},
    %{txoid: "input:2", amount: 200.00},
    %{txoid: "input:3", amount: 60.00}
]

IO.inspect is_list(init_coins)

  IO.inspect init_coins
  node1 = Enum.at(nodes,0)
  IO.inspect node1
  node2 = Enum.at(nodes,1)
  pid = self
  IO.inspect pid

#   FullNode.call(pid,{:add_coins,coin_list})
  FullNode.add_coins(node1,init_coins)

  IO.inspect "before trans"
  FullNode.print_state(node1)
  FullNode.print_state(node2)

  FullNode.make_transaction(node1,node2,50)

  FullNode.print_state(node1)
  FullNode.print_state(node2)

  


