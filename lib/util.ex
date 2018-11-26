defmodule Util do
    def zero_pad(bytes, size) do
        String.duplicate(<<0>>, size - byte_size(bytes)) <> bytes
    end
end


defmodule Topology do
    
   
    #Helpers for building topology

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

    def add_peer(pid, node) do
        FullNode.cast(pid, {:add, node})
    end
      
    def add_peers(pid, pidList) do
        for x <- 0..Enum.count(pidList)-1 do
          add_peer(pid, Enum.at(pidList,x))
        end
    end

end


defmodule Crypto do
    def get_hex_sha256_hash(input) do
        :crypto.hash(:sha256, input) |> Base.encode16
    end
end



defmodule Merkle do
    def calculate_merkle_root(list) do
        list
        |> Enum.chunk_every(2)
        |> Enum.map(&Crypto.get_hex_sha256_hash(&1))
        |> calculate_merkle_root(true)
    end

    def calculate_merkle_root(list, true) when length(list) == 1, do: hd(list)
    def calculate_merkle_root(list, true), do: calculate_merkle_root(list)
  
end