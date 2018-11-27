defmodule Mine do
    @starting_nonce 0
    @nonce_increment 1
    @nonce_limit 100000000
    require Integer
    defguardp valid_nonce?(nonce) when nonce <= @nonce_limit

  def proof_of_work(header,nonce, difficulty_bits)
       when valid_nonce?(nonce) do
    target = pow(2, 256 - difficulty_bits)

    hash_result =
      :sha256
      |> :crypto.hash(to_string(header) <> to_string(nonce))
      |> Base.encode16(case: :lower)
      

    case String.to_integer(hash_result, 16) do
      result when result < target ->
                  {hash_result, nonce}
      _more_than_target ->
                  proof_of_work( header, nonce + @nonce_increment, difficulty_bits)
    end
  end

  def proof_of_work(_header, nonce, _difficulty_bits) do
    IO.puts("Failed after #{nonce} (max_nonce) tries")
    {nil, nonce}
  end

  def pow(_n, 0), do: 1
  def pow(n, exp) when Integer.is_odd(exp), do: n * pow(n, exp - 1)

  def pow(n, exp) do
    result = pow(n, div(exp, 2))
    result * result
  end

end

