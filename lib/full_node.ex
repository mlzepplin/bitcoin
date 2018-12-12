defmodule FullNode do

    @target  4
    @transaction_limit  1
    @coinbase_reward 10
    use GenServer


    ##################### representations #####################
    # FullNode's state: { public_key, private_key, balance, num_blocks, block_chain, transaction_buffer, input_pool }
    # block's state: {index, block_header, transaction_list,input_hashes_set, transaction_hashes_set}
    # possibly? - all_merkel_hashes 
    # block_header's state: {prev_hash, nocne, merkel_root}
    ###########################################################
    ######################### client side #####################
    # def start_up(default) do
    #   {:ok,node_pid} = GenServer.start_link(__MODULE__, default)
    #   node_pid
    # end

    def start_link(opts) do
         GenServer.start_link(__MODULE__, opts)
        
    end

    def init(args) do
      {:ok, args}
    end

    def mine(pid) do
        GenServer.cast(pid,{:mine})
    end
   

    def broadcast_transaction(transaction, sender_pid) do
        PubSub.publish("bitcoin_transactions", {:transaction, transaction, sender_pid})
    end

    def broadcast_block(block, sender_pid) do
        PubSub.publish("mined_blocks", {:block, block, sender_pid})
    end

    def receive_transaction(transaction) do
        GenServer.cast(self(), {:tx_receiver,transaction} )
    end

    def receive_block(block) do
        GenServer.cast(self(), {:block_receiver,block})
    end

    def make_transaction(pid,send_to,amount) do
        # verifies if inputs are not being double spent
        # makes the transaction 
        # broadcasts the transaction
        GenServer.cast(pid,{:transact, {send_to,amount}})
        
    end

    def add_coins(pid,coin_list) do
 
        GenServer.call(pid,{:add_coins,coin_list})
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

    def print_state(pid) do
        GenServer.call(pid, :print_state)
    end

    def recur(block,[]) do
        block
    end
    def recur(block,[head|tail]) do
        block =  Block.add_transaction(block,head)
        recur(block,tail)
    end

#     ################### server side ###################

    # mine
    def handle_cast({:mine}, { public_key, private_key, balance, block_chain, transaction_buffer, input_pool }) do
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
        coinbase_transaction = Transaction.generate_coinbase(@coinbase_reward,self())
        coinbase_input = %{txoid: coinbase_transaction.id, amount: @coinbase_reward}
        current_block = Block.add_transaction(current_block,coinbase_transaction)

        # pop out transactions from the buffer and fill em up in the current_block

        tx_for_block = Enum.slice(transaction_buffer,0..@transaction_limit-1)
        new_transaction_buffer = Enum.slice(transaction_buffer,@transaction_limit..length(transaction_buffer)-1)
        

        new_current_block = recur(current_block,tx_for_block)
        

        # mine for bitcoin and increment your balance
        updated_block = Block.mine(new_current_block)

        # TODO - BROADCAST THIS BLOCK TO ALL OTHER NODES
        broadcast_block(updated_block, self)
        
        {:noreply, { public_key,private_key,balance,block_chain, transaction_buffer,input_pool}}

    end

    # make transaction
    def handle_cast({:transact,{send_to,amount}},{ public_key, private_key, balance, block_chain, transaction_buffer, input_pool }) do
        # check if you have enough balance 
        if(balance>=amount) do
            # pick the first few inputs that sum to >= amount_to_send
            {sum, input_list, updated_input_pool} = slice_input_pool(amount, input_pool)
            # def generate_transaction(sender,input_list,send_to,send_amount)
            tx = Transaction.generate_transaction(self(), input_list, send_to, amount)
             
            # TODO -- > Broadcast transaction
            broadcast_transaction(tx, self)
            {:noreply,{public_key, private_key, balance - sum, block_chain, [tx | transaction_buffer], updated_input_pool }}
        else
            # no transaction can be made as insufficient balance 
            {:noreply,{public_key, private_key, balance, block_chain, transaction_buffer, input_pool }}
        end
    end

    # receive block
    def handle_cast({:block_receiver,received_block},{public_key, private_key, balance, block_chain, transaction_buffer, input_pool }) do
        ################
        # TODO stop mining when you received a block
        ###############
        # we are assuming , no attackers in the system, and only honest nodes
        new_block_chain  =  [received_block | block_chain]
        coins_for_me = Block.get_my_coins_from_block(received_block, self())
        new_transaction_buffer = Block.update_transaction_buffer(received_block,transaction_buffer)
        if length(coins_for_me) != 0 do
            new_input_pool = List.flatten [coins_for_me | input_pool]
            sum = Transaction.sum_inputs(coins_for_me)
            {:noreply,{public_key, private_key, balance + sum, new_block_chain, new_transaction_buffer, new_input_pool }}
        else
            {:noreply,{public_key, private_key, balance, new_block_chain, new_transaction_buffer, input_pool }}
        end

    end 

    # receive transaction
    def handle_call({:tx_receiver,received_tx}, _from, {public_key, private_key, balance, block_chain, transaction_buffer, input_pool }) do
        block_size_reached = if ((length(transaction_buffer) + 1) == @transaction_limit) do
                                    :true
                                else
                                    :false
                                end
                            
        {:reply, block_size_reached, {public_key, private_key, balance, block_chain,[received_tx| transaction_buffer], input_pool }}
    end

    def handle_call({:add_coins, coin_list}, _from, {public_key, private_key, balance, block_chain, transaction_buffer, input_pool}) do
        new_input_pool = List.flatten [coin_list | input_pool]

        {:reply, :added, {public_key, private_key, balance + Transaction.sum_inputs(coin_list), block_chain,transaction_buffer, new_input_pool}}
    end

    def handle_call(:print_state, _from, state) do
        IO.inspect state
        {:reply, :printed, state}
    end



end