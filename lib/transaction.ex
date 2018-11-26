defmodule Transaction do
        defstruct id: nil,
            inputs: [],
            outputs: [],
            txtype: "P2PK" #pay-to-public-key

  @spec compute_outputs(Transaction, Map) :: %{outputs: list, fee: Decimal}
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

  @spec calculate_hash(Transaction) :: String.t()
  def calculate_hash(transaction) do
    transaction.inputs
    |> Enum.map(& &1.txoid)
    |> Merkle.calculate_merkle_root()
  end

  
  @spec generate_coinbase(Decimal, String.t()) :: Transaction
  def generate_coinbase(amount, miner_address) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    txid = Crypto.get_hex_sha256_hash(miner_address <> timestamp)

    %Transaction{
      id: txid,
      txtype: "COINBASE",
      outputs: [
        %Out_coin{txoid: "#{txid}:0", addr: miner_address, amount: amount}
      ]
    }
  end

  @spec sum_inputs(list) :: Decimal
  def sum_inputs(inputs) do
    Enum.reduce(inputs, D.new(0), fn %{amount: amount}, acc -> D.add(amount, acc) end)
  end

  @spec calculate_fee(Transaction) :: Decimal
  def calculate_fee(transaction) do
    D.sub(sum_inputs(transaction.inputs), sum_inputs(transaction.outputs))
  end

end



