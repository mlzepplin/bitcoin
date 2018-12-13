defmodule Util do
    def zero_pad(bytes, size) do
        String.duplicate(<<0>>, size - byte_size(bytes)) <> bytes
    end

    def create_network_nodes(num_nodes) do
        nodes = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_network_node() end) 
         
      end
    
    #State { public_key, private_key, balance, blockchain, transaction_buffer, input_pool }
    def create_network_node() do
        
        {pub_key, priv_key} = Signature.create_keypair()
        {:ok, pid} = FullNode.start_link({pub_key, priv_key, 0.0, [], [], []}) #neighbor list
        PubSub.subscribe("bitcoin_transactions", pid)
        PubSub.subscribe("mined_blocks", pid)
        pid
    
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
    def calculate_merkle_root(list, true) when length(list) == 0, do: Crypto.get_hex_sha256_hash("")
    def calculate_merkle_root(list, true) when length(list) == 1, do: hd(list)
    def calculate_merkle_root(list, true), do: calculate_merkle_root(list)
  
end