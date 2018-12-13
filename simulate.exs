num_args = length(System.argv)

nodes = List.first(System.argv)
transactions = List.last(System.argv)


#Bitcoin.Manager.init(:foo)
Bitcoin.Manager.start_link({[], []})
Bitcoin.Manager.simulate(nodes, transactions)
  


IO.inspect "Simulation done"
state = GenServer.call(Manager, :get_state)
IO.inspect state