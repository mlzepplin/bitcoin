defmodule Signature do
    use Bitwise
    require Integer

  @algorithm :ecdh
  @sigtype :ecdsa
  @curve :secp256k1
  @hashtype :sha256
  

  # Creates a new keypair and stores the private key in a keyfile. Returns the public and private key
  @spec create_keypair :: {binary, binary}
  def create_keypair do
    keypair = :crypto.generate_key(@algorithm, @curve)
    #create_keyfile(keypair)
    keypair
  end

  @spec sign(binary, String.t()) :: String.t()
  def sign(private_key, data) do
    :crypto.sign(@sigtype, @hashtype, data, [private_key, @curve])
  end

  @spec verify_signature(binary, binary, String.t()) :: boolean
  def verify_signature(public_key, signature, data) do
    :crypto.verify(@sigtype, @hashtype, data, signature, [public_key, @curve])
  end

end


