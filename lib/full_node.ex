defmodule FullNode do

    @target  4
    @transaction_limit  4
    @coinbase_reward 10
    use GenServer
    ##################### representations #####################
    # FullNode's state: { public_key, private_key, balance, num_blocks, block_chain, transaction_buffer, input_pool }
    # block's state: {index, block_header, transaction_list,input_hashes_set, transaction_hashes_set}
    # possibly? - all_merkel_hashes 
    # block_header's state: {prev_hash, nocne, merkel_root}
    ###########################################################
    ######################### client side #####################
    def start_up(default) do
      {:ok,main_pid} = GenServer.start_link(__MODULE__, default)
      main_pid
    end

    def init(args) do
      {:ok, args}
    end

    def mine() do
        Genserver.cast(self(),{:mine})
    end
   
    def make_transaction() do
     
    end

    def broadcast_block(block) do
        
    end

    def make_trasaction(send_to,amount) do
        # verifies if inputs are not being double spent
        # makes the transaction 
        # broadcasts the transaction
        GenServer.cast(self(),{:send_money,send_to,amount})
        
    end
    
    def broadcast_transaction(transaction) do
        
    end

    def verify_transaction_in_blockchain(transaction) do
        
    end

    # methods to slice input_pool according to required_amount
    def find_slice_index(running_sum,req_amount,input_pool,pos) do
        s = running_sum + Enum.at(input_pool,pos).amount
        {sum,index} = if s < req_amount do
                        find_slice_index(s,req_amount,input_pool,pos+1)
                    else
                        {s,pos}
                    end
    end

    def slice_input_pool(required_sum,input_pool) do
       
        {sum,index} = find_slice_index(0,required_sum,input_pool,0)
        left_slice = Enum.slice(input_pool, 0, index+1)
        right_slice = 
            if length(left_slice) != length(input_pool) do
                Enum.slice(input_pool, index+1, length(input_pool))
            else
                []
            end
        {sum,left_slice,right_slice}
    end

#     ################### server side ###################
    def handle_cast({:mine}, { public_key,private_key,balance, block_chain, transaction_buffer, input_pool }) do
        #NOTE : THIS EXPECTS TRANSACTION_BUFFER TO ATLEAST HAVE transaction_limit number of records
        # treating public key as the address itself
        current_block = 
        if(length(block_chain)==0) do 
            Block.initialize()
        else
            # passing the previous_block to init this block
            Block.initialize(hd(block_chain))
        end
        # adding the initial coinbase transaction
        coinbase_transaction = Transaction.generate_coinbase(@coinbase_reward,public_key)
        coinbase_input = %{txoid: coinbase_transaction.id, amount: @coinbase_reward}
        current_block = Block.add_transaction(current_block,coinbase_transaction)

        # pop out transactions from the buffer and fill em up in the current_block
        for x <- 0..@transaction_limit-1 do
            temp_transaction = hd(transaction_buffer)
            transaction_buffer = tl(transaction_buffer)
            current_block = Block.add_transaction(current_block,temp_transaction)
        end

        # mine for bitcoin and increment your balance
        current_block = Block.mine(current_block)

        # TODO - BROADCAST THIS BLOCK TO ALL OTHER NODES
        broadcast_block(current_block)
        
        {:noreply, { public_key,private_key,balance + @coinbase_reward,[current_block | block_chain], transaction_buffer,[coinbase_input| input_pool]}}

    end

    def handle_cast({:transact,{send_to,amount}},{ public_key, private_key, balance, block_chain, transaction_buffer, input_pool }) do
        # check if you have enough balance 
        if(balance>=amount) do
            # pick the first few inputs that sum to >= amount_to_send
            {sum, input_list, updated_input_pool} = slice_input_pool(amount, input_pool)
            # def generate_transaction(sender,input_list,send_to,send_amount)
            tx = Transaction.generate_transaction(public_key, input_list, send_to, amount)
             
            # TODO -- > Broadcast transaction
            broadcast_transaction(tx)
            {:noreply,{public_key, private_key, balance - sum, block_chain, [tx | transaction_buffer], updated_input_pool }}
        else
            # no transaction can be made as insufficient balance 
            {:noreply,{public_key, private_key, balance, block_chain, transaction_buffer, input_pool }}
        end
    end

    def handle_cast({:block_reciever,recieved_block},{public_key, private_key, balance, block_chain, transaction_buffer, input_pool }) do
        # stop mining when you recieved a block
        # we are assuming , no attackers in the system, and only honest nodes
        trasaction_list = recieved_block.transactions
    end 



end