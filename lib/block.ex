ExUnit.start()
defmodule Block do
    @difficulty 16

    defstruct index: 0,
              hash: nil,
              previous_hash: nil,
              nonce: 0,
              timestamp: nil,
              merkle_root: "",
              transactions: []

    def header(block) do
        %{
            hash: block.hash,
            index: block.index,
            previous_hash: block.previous_hash,
            merkle_root: block.merkle_root,
            nonce: block.nonce,
            timestamp: block.timestamp
        }
    end

    #create first block in blockchain
    def initialize do
        %Block{
          timestamp: get_unix_time(),
          previous_hash: String.duplicate(<<0>>, 64) # 64 bytes of 0
        }
    end

    #create new block based on previous block
    def initialize(%{index: index, hash: previous_hash}) do
        index = index |> Kernel.+(1)

    
        block = %Block{
          index: index,
          previous_hash: previous_hash,
          timestamp: get_unix_time()
        }
        Map.put(block, :difficulty, @difficulty)
    end


    def calculate_block_hash(block) do
        %{
          index: index,
          previous_hash: previous_hash,
          timestamp: timestamp,
          nonce: nonce,
          merkle_root: merkle_root
        } = block
    
        Crypto.get_hex_sha256_hash([
          Integer.to_string(index),
          previous_hash,
          Integer.to_string(timestamp),
          Integer.to_string(nonce),
          merkle_root
        ])
    end

    def mine(block) do
        header =  block.previous_hash <> block.merkle_root

        {_, resultant_nonce} = Mine.proof_of_work(header, 0, @difficulty)
        block = Map.put(block, :nonce, resultant_nonce)
        block = Map.put(block, :hash, calculate_block_hash(block))
        
    end

    defp get_unix_time do
        DateTime.utc_now() |> DateTime.to_unix()
    end

end
