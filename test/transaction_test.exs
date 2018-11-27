ExUnit.start(trace: true)
defmodule TransactionTest do
  use ExUnit.Case
  doctest Transaction
  
  test "transaction test: generating the first coinbase transaction" do
   
    # treat public key as the address itself, since we are neglecting the checksum functionality
    {pub1,priv1} = Signature.create_keypair()
    
    generated_transaction = Enum.at(Transaction.generate_coinbase(1,pub1).outputs,0)
    
    # coinbase transaction comes back to the miner
    assert generated_transaction.addr == pub1

    # we've set the amount of the coinbase transaction to be 1 BTC
    assert generated_transaction.amount == 1
    
    #coinbase transaction should be the first transaction ,i.e. with tx_output_id ending in  ':0'
    assert String.slice(generated_transaction.txoid, -2..-1) == ":0"

  end

  test "computing transaction outputs correctly" do
   
    {pub1,priv1} = Signature.create_keypair()
    tx = %Transaction{
      inputs: [
        %{txoid: "input:0", amount: 100.00},
        %{txoid: "input:4", amount: 40.33},
      ]
    }
     # creating a designations map
    designations = [
      %{addr: "reciever1", amount: 50},
      %{addr: "reciever2", amount: 80}
    ]
    # note transaction id is calculated only on the basis of inputs
    # and later is used to assign tx_output_id (txoid) as {txid:#}
    tx = %{tx | id: Transaction.calculate_hash(tx)}

    ground_truth = %{
      outputs: [
        %{
          addr: "reciever1",
          amount: 50,
          txoid: "43C97B8FA842AC1689CC6ED285F53CAC2569CC6CBE1FA2FF3DEB1F35AEC88088:0"
        },
        %{
          addr: "reciever2",
          amount: 80,
          txoid: "43C97B8FA842AC1689CC6ED285F53CAC2569CC6CBE1FA2FF3DEB1F35AEC88088:1"
        }
      ]
    }

    assert Transaction.compute_outputs(tx,designations) == ground_truth

  end



end