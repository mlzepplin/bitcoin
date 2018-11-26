ExUnit.start()
defmodule BitcoinTest do
  use ExUnit.Case
  #use Signature

  doctest Bitcoin

  test "greets the world" do
    assert Bitcoin.hello() == :world
  end

  test "gives correct hash" do
    hash = "B4056DF6691F8DC72E56302DDAD345D65FEAD3EAD9299609A826E2344EB63AA4"
    computed_hash = Crypto.get_hex_sha256_hash("Bitcoin")
    assert computed_hash == hash 
  end

  test "calculates merkle root" do
    txns = ["a","b", "c","d"]

    txns_combined = Enum.chunk_every(txns,2)
    
    merkle_hashes = Enum.map(txns_combined, fn(x) -> Crypto.get_hex_sha256_hash(x) end)
    merkle_root = Crypto.get_hex_sha256_hash(merkle_hashes)
    

    computed_merkle_root = Merkle.calculate_merkle_root(txns)
    assert merkle_root == computed_merkle_root
  end

  test "calculates merkle root with odd number of transactions" do
    txns = ["a","b", "c"]
    txns_combined = Enum.chunk_every(txns,2)
    
    merkle_hashes = Enum.map(txns_combined, fn(x) -> Crypto.get_hex_sha256_hash(x) end)
    merkle_root = Crypto.get_hex_sha256_hash(merkle_hashes)
    

    computed_merkle_root = Merkle.calculate_merkle_root(txns)
    assert merkle_root == computed_merkle_root

  end

  test "signing data and verifying signature" do
    #create a key-pair
    {public_key,private_key} = Signature.create_keypair()
    
    #sign off some data with it
    data = "hey there! sign me!"
    signature = Signature.sign(private_key,data)
    
    #assert using the public key, if that transaction ws signed 
    assert Signature.verify_signature(public_key,signature,data) == true
  end


  test "nonce computation / proof of work" do
    
    test_string = "this is a test string"
    previous_block_hash = "B4056DF6691F8DC72E56302DDAD345D65FEAD3EAD9299609A826E2344EB63AA4"
    difficulty_bits = 16 # should return a hash value with the first 4 bits as 0
    {hash_result, nonce} =
        test_string
        |> Kernel.<>(previous_block_hash)
        |> Mine.proof_of_work(0,difficulty_bits)
     
     IO.puts("nonce #{nonce}")
     IO.puts("Hash #{hash_result}")

     #first 4 bits
     assert  String.slice(hash_result, 0..3) == "0000"
  end

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

  test "computing outputs and summing " do
   
    {pub1,priv1} = Signature.create_keypair()
    # creating a designations map


    #retrieving the output of the map



  end

end
