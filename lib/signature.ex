defmodule Signature do
    use Bitwise
    require Integer

  @algorithm :ecdh
  @sigtype :ecdsa
  @curve :secp256k1
  @hashtype :sha256
  

  # Creates a new keypair. Returns the public and private key
  def create_keypair do
    keypair = :crypto.generate_key(@algorithm, @curve)
    keypair
  end

  def sign(private_key, data) do
    :crypto.sign(@sigtype, @hashtype, data, [private_key, @curve])
  end

  def verify_signature(public_key, signature, data) do
    :crypto.verify(@sigtype, @hashtype, data, signature, [public_key, @curve])
  end

end


