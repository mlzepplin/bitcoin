defmodule FullNode do

    @target = 4
    @transaction_limit = 4
    use GenServer
    ##################### representations #####################
    # FullNode's state: { balance, num_blocks, block_chain, current_block,transaction_buffer }
    # block's state: {index, block_header, transaction_list,input_hashes_set, transaction_hashes_set}
    # possibly? - all_merkel_hashes 
    # block_header's state: {prev_hash, nocne, merkel_root}
    #################################################



    ############### client side ####################
    def start_up(default) do
      {:ok,main_pid} = GenServer.start_link(__MODULE__, default)
      main_pid
    end

    def init(args) do
      {:ok, args}
    end

    #keep searching till 'target' number of zeros are found at beginning
    def mine() do
      prev_block_hash = get_prev_block_hash
      nonce = 0

    end

    def compute_merkel_root() do
        
    end

    def add_incentive() do
        
    end

    def broadcast_block() do
        
    end

    def make_trasaction(send_to,amount) do
        # verifies if inputs are not being double spent
        # makes the transaction 
        # broadcasts the transaction
        GenServer.cast(self(),{:send_money,send_to,amount})
        
    end
    
    def broadcast_transaction() do
        
    end

    ################### server side ###################

  def handle_cast({:send_money,send_to,amount}, { balance, num_blocks, block_chain, current_block,transaction_buffer }) do
    #IO.puts "received cast"
    if (amount <= balance) do
        Genserver.cast(send_to,{:recieve_money,amount})
        # TODO broadcast_transaction(self(),send_to,amount)
        IO.puts "money sent!!"
        {:noreply, { balance-amount, num_blocks, block_chain, current_block,transaction_buffer }}
    else
        {:noreply, { balance, num_blocks, block_chain, current_block,transaction_buffer }}
    end
  end

  def handle_cast({:recieve_money,amount},{ balance, num_blocks, block_chain, current_block,transaction_buffer }) do
    # TODO : validate transaction for double-spending
    {:noreply, { balance+amount, num_blocks, block_chain, current_block,transaction_buffer }}
  end
 
  #representation of a transaction {input,output,amount}
  def handle_cast({:recieve_transaction_broadcast,transaction}, { balance, num_blocks, block_chain, current_block,trasaction_buffer_count,transaction_buffer }) do
    # append the transaction to the transaction_buffer
    # if length of buffer increases more than transaction limit -- start to mine
    if transaction_buffer_count+1 == @transaction_limit do
      Genserver.cast(self(),:mine)
    end
    {:noreply, { balance, num_blocks, block_chain, current_block,trasaction_buffer_count+1,[transaction_buffer|transaction]}}
  end

  def handle_cast(:mine,{ balance, num_blocks, block_chain, {prev_hash,nonce,merkel_root},trasaction_buffer_count,transaction_buffer }) do
    # pop the first transaction_limit  number of transacton from the transaction_buffer (which is a list)
    #compute merkel_root

    #now concat prev_block's_header's_hash and a nonce

    # iterate with varying values of hash
    
    # try to mine for nonce, as soon as done, update own block_cahin and broadcast block to all
  

  end

    # TODO ?
    # will be informed of incoming latest transactions
    # will be informed of accepted new blocks as well

    # as soon as the transactions hit a limit
    # start mining, and ignore all further incoming transactions
    # meanwhile if a block got accepted, and that had a transaction that we were
    # wornig on, then redo

      def add_peer(pid, item) do
        GenServer.cast(pid, {:push, item})
      end
    
      def add_peers(pid, pidList) do
        for x <- 0..Enum.count(pidList)-1 do
          add_peer(pid, Enum.at(pidList,x))
        end
    end

end