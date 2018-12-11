defmodule Transaction do
  require Float
        defstruct id: nil,
            inputs: [],
            outputs: []

  def compute_outputs(transaction, designations) do
    outputs =
      designations
      |> Enum.with_index()
      |> Enum.map(fn {designation, idx} ->
        %{
          txoid: "#{transaction.id}:#{idx}",
          addr: designation.addr,
          amount: designation.amount
        }
      end)
    %{outputs: outputs}
  end

  def calculate_hash(transaction) do
    transaction.inputs
    |> Enum.map(& &1.txoid)
    |> Merkle.calculate_merkle_root()
  end

  
  def generate_coinbase(amount, miner_address) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    txid = Crypto.get_hex_sha256_hash(timestamp)
    # returns this transaction
    %Transaction{
      id: txid,
      outputs: [
        %OutCoin{txoid: "#{txid}:0", addr: miner_address, amount: amount}
      ]
    }
  end

  def generate_transaction(sender,input_list,send_to,send_amount) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    txid = Crypto.get_hex_sha256_hash(timestamp)
    tx = %Transaction{
      inputs: input_list
    }
    # creating a designations map
    input_sum = sum_inputs(input_list)
    designations = 
      if input_sum == send_amount do
        [%{addr: send_to, amount: send_amount}]
      else
        [
          %{addr: send_to, amount: send_amount},
          %{addr: sender, amount: input_sum - send_amount} # return the sender , the change, if any
        ]
      end
    # note transaction id is calculated only on the basis of inputs
    # and later is used to assign tx_output_id (txoid) as {txid:#}
    tx = %{tx | id: Transaction.calculate_hash(tx)}
    output_list = compute_outputs(tx,designations).outputs
    #IO.inspect output_list
    tx = %{tx | outputs: output_list}
  end

  def sum_inputs(inputs) do
    Enum.reduce(inputs, 0, fn %{amount: amount}, acc -> (amount + acc) end)
  end


end



