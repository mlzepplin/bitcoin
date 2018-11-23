num_args = length(System.argv)

num_nodes = String.to_integer(List.first(System.argv))

#simple termination criteria
time_to_run = String.to_integer(List.last(System.argv))


#build a network of full connected nodes
nodes = Bitcoin.create_network_nodes(num_nodes, main_pid)
Bitcoin.set_peers(nodes)