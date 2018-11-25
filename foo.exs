txns = ["a","b", "c","d"]

    txns_combined = Enum.chunk_every(txns,2)
    
    merkle_hashes = Enum.map(txns_combined, fn(x) -> Crypto.get_hex_sha256_hash(x) end)
    merkle_root = Crypto.get_hex_sha256_hash(merkle_hashes)
    

    computed_merkle_root = Merkle.calculate_merkle_root(txns)

    IO.inspect merkle_root
    IO.inspect computed_merkle_root