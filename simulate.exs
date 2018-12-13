num_args = length(System.argv)

nodes = List.first(System.argv)
transactions = List.last(System.argv)


Bitcoin.Manager.init(:foo)
Bitcoin.Manager.simulate(nodes, transactions)
  


