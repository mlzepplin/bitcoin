defmodule Block do
    @difficulty 16

    defstruct index: 0,
              hash: "0",
              previous_hash: "0",
              nonce: 0,
              timestamp: "0",
              merkle_root: "0",
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
          index,
          previous_hash,
          timestamp,
          nonce,
          merkle_root
        ])
    end

    def mine(block) do
        block = Map.put(block, :hash, calculate_block_hash(block))
        resultant_nonce = Mine.proof_of_work(block.hash,0,@difficulty)
        block = %{block | nonce: resultant_nonce}
    end

    def hash_less_than_target?(%{hash: hash, difficulty: @difficulty}) do
        {integer_value_of_hash, _} = Integer.parse(hash, 16)
        integer_value_of_hash < calculate_target(@difficulty)
    end

    defp get_unix_time do
        DateTime.utc_now() |> DateTime.to_unix()
    end

    def calculate_target(@difficulty), do: round((:math.pow(16, 64) / @difficulty)) - 1


    
    


end
