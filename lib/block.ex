defmodule Block do
    @difficulty 16

    defstruct index: <<0, 0, 0, 0>>,
              hash: nil,
              previous_hash: nil,
              nonce: <<0, 0, 0, 0, 0, 0, 0, 0>>,
              timestamp: nil,
              merkle_root: nil,
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
        index =
          index
          |> :binary.decode_unsigned()
          |> Kernel.+(1)
          |> :binary.encode_unsigned()
          |> Utilities.zero_pad(4)
    
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

        if hash_less_than_target?(block) do
            block
        else
            #reset nonce to zero and update timestamp if nonce overflows
            if block.nonce == <<255, 255, 255, 255, 255, 255, 255, 255>> do
                mine(%{block | nonce: <<0, 0, 0, 0, 0, 0, 0, 0>>, timestamp: get_unix_time()})
              else
                nonce =
                  block.nonce
                  |> :binary.decode_unsigned()
                  |> Kernel.+(1)
                  |> :binary.encode_unsigned()
                  |> Util.zero_pad(8) # Add trailing zero bytes since they're removed when encoding / decoding
        
                mine(%{block | nonce: nonce})
            end
        end
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
