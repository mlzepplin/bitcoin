ExUnit.start()
defmodule MingingTest do
    use ExUnit.Case
    doctest Mine
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
end