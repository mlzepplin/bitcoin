ExUnit.start(trace: true)
defmodule BitcoinTest do
  use ExUnit.Case


  test "gives correct sha-256 hash" do
    hash = "B4056DF6691F8DC72E56302DDAD345D65FEAD3EAD9299609A826E2344EB63AA4"
    computed_hash = Crypto.get_hex_sha256_hash("Bitcoin")
    assert computed_hash == hash 
  end

  test "calculates merkle root of transactions" do
    txns = ["a", "b", "c", "d"]

    txns_combined = Enum.chunk_every(txns,2)
    
    merkle_hashes = Enum.map(txns_combined, fn(x) -> Crypto.get_hex_sha256_hash(x) end)
    merkle_root = Crypto.get_hex_sha256_hash(merkle_hashes)
    
    computed_merkle_root = Merkle.calculate_merkle_root(txns)
    assert merkle_root == computed_merkle_root
  end

  test "calculates merkle root of odd number of transactions" do
    txns = ["a","b", "c"]
    txns_combined = Enum.chunk_every(txns,2)
    
    merkle_hashes = Enum.map(txns_combined, fn(x) -> Crypto.get_hex_sha256_hash(x) end)
    merkle_root = Crypto.get_hex_sha256_hash(merkle_hashes)
    
    computed_merkle_root = Merkle.calculate_merkle_root(txns)
    assert merkle_root == computed_merkle_root

  end

end
