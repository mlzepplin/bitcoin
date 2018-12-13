defmodule Bitcoin.Manager do
    use GenServer

    def init(args) do
        {:ok, args}
    end

    def simulate(nodes, transactions) do

        num_nodes = String.to_integer(nodes)
        num_transactions = String.to_integer(transactions)

        #create nodes in bitcoin network
        nodes = Util.create_network_nodes(num_nodes)
        IO.inspect nodes

        #Initialize all nodes with random number of bitcoins
        init_coins = [
            %{txoid: "input:0", amount: 100.00},
            %{txoid: "input:1", amount: 40},
            %{txoid: "input:2", amount: 200.00},
            %{txoid: "input:3", amount: 60.00}
        ]
        Enum.each(nodes, fn(node) -> GenServer.call(node, {:add_coins,init_coins}) end)

        #perform random transactions
        for count <- 1..num_transactions do
            node1 = Enum.random(nodes)
            node2 = Enum.random(nodes)

            # IO.inspect "before trans"
            FullNode.print_state(node1)
            FullNode.print_state(node2)

            #make transaction
            FullNode.make_transaction(node1,node2,5)
            :timer.sleep(1000)

            #after transaction
            FullNode.print_state(node1)
            FullNode.print_state(node2)

        end
    end


end
