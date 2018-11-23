defmodule FullNode do

    @target = 4
    use GenServer
    ##################### representations #####################
    # FullNode's state: { num_blocks, blocks, current_block,transaction_buffer }
    # block's state: {index, block_header, transaction_list,,input_hashes_set, transaction_hashes_set}
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

    def make_trasaction() do
        # verifies if inputs are not being double spent
        # makes the transaction 
        # broadcasts the transaction
    end
    
    def broadcast_transaction() do
        
    end

    ################### server side ###################




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