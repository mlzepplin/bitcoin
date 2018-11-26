ExUnit.start()
defmodule SignatureTest do
  use ExUnit.Case
  doctest Signature   
  test "signing data and verifying signature" do
    #create a key-pair
    {public_key,private_key} = Signature.create_keypair()
    
    #sign off some data with it
    data = "hey there! sign me!"
    signature = Signature.sign(private_key,data)
    
    #assert using the public key, if that transaction ws signed 
    assert Signature.verify_signature(public_key,signature,data) == true
  end

end