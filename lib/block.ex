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
       
        transaction_hash_list = Enum.map(block.transactions,fn(t) -> Transaction.calculate_hash(t) end)
        block = Map.put(block,:merkle_root,Merkle.calculate_merkle_root(transaction_hash_list))
        
        header =  block.previous_hash <> block.merkle_root
        {_, resultant_nonce} = Mine.proof_of_work(header, 0, @difficulty)
        block = Map.put(block, :nonce, resultant_nonce)
        block = Map.put(block, :hash, calculate_block_hash(block))
        
    end

    def add_transaction(block,transaction) do
        transaction_list = block.transactions
        new_transaction_list = [transaction|transaction_list]
        block = Map.put(block, :transactions,new_transaction_list)
    end

    def set_transaction_list(block,transaction_list) do
        block = Map.put(block, :trasactions, transaction_list)
    end

    defp get_unix_time do
        DateTime.utc_now() |> DateTime.to_unix()
    end
    
    def recurse_tl(node,[]) do [] end 
    def recurse_tl(node,[tx|tail]) do
        head_coins = recurse_cl(node, tx.outputs)
        tail_coins = recurse_tl(node,tail)
        List.flatten [head_coins,tail_coins]
    end

    def recurse_cl(node,[]) do [] end
    def recurse_cl(node,[head|tail]) do
        head_coin = 
        if head.addr == node do
            head
        else
            []
        end
        tail_coins = recurse_cl(node,tail)
        List.flatten [head_coin,tail_coins]
    end

    
    def get_my_coins_from_block(block,node) do
        # this will just be returning the list of all the coins 
        # that are to be added to the said node's input_pool
        result = recurse_tl(node,block.transactions) 
    end

    def recurse_buffer(tx,[]) do [] end
    def recurse_buffer(tx,[head|buffer_tail]) do
        head_tx = 
        if head.id != tx.id do
            head
        else
            []
        end
        tail_tx = recurse_buffer(tx,buffer_tail)
        List.flatten [head_tx,tail_tx]
    end

    def recurse_block_tx([],buffer) do [] end 
    def recurse_block_tx([tx|tail],buffer) do
        head_tx = recurse_buffer(tx,buffer)
        tail_tx = recurse_block_tx(tail,head_tx)
        List.flatten tail_tx
    end
        
    def update_transaction_buffer(block,tx_buffer) do
        result = recurse_block_tx(block.transactions, tx_buffer)
    end

end
