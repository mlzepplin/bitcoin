defmodule OutCoin do
    defstruct [:addr, :amount, :txoid, :signature]
    def hash(out_coin) do
      :crypto.hash(:sha256, [out_coin.txoid, out_coin.addr, :erlang.term_to_binary(out_coin.amount)])
    end
  end