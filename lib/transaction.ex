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
    txid = Crypto.get_hex_sha256_hash(miner_address <> timestamp)
    # returns this transaction
    %Transaction{
      id: txid,
      outputs: [
        %OutCoin{txoid: "#{txid}:0", addr: miner_address, amount: amount}
      ]
    }
  end

  def sum_inputs(inputs) do
    Enum.reduce(inputs, 0, fn %{amount: amount}, acc -> (amount + acc) end)
  end

  def calculate_fee(transaction) do
    Decimal.sub(sum_inputs(transaction.inputs), sum_inputs(transaction.outputs))
  end

end



