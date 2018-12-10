ExUnit.start(trace: true)
defmodule BlockTest do
    use ExUnit.Case

    test "can generate first block in blockchain" do
        first_block = Block.initialize() |> Block.mine()
        
        assert first_block.index == 0
        assert first_block.hash == Block.calculate_block_hash(first_block)

    end

    test "can create a new block" do
        first_block = Block.initialize()
        block = first_block |> Block.initialize()

        assert block.index == first_block.index + 1
        assert block.previous_hash == first_block.hash
    end

    test "can mine a block" do
        first_block = Block.initialize() |> Block.mine()
        
        block = first_block |> Block.initialize() |> Block.mine()
        
        assert block.hash != nil

    end

    test "add transaction to block" do
        first_block = Block.initialize()
        tx = %Transaction{
            inputs: [
              %{txoid: "input:0", amount: 100.00},
              %{txoid: "input:4", amount: 40.33},
            ],
            outputs: [
              %{addr: "pid", txoid: "aaaa", amount: 100.00},
              %{addr: "pid", txoid: "aaaab", amount: 10.00}
            ]
        }
        block = first_block |> Block.initialize() |> Block.add_transaction(tx)
        assert [tx] == block.transactions 

    end

    test "get all coins from a block meant for a node" do
        first_block = Block.initialize()
        tx = %Transaction{
            inputs: [
              %{txoid: "input:0", amount: 100.00},
              %{txoid: "input:4", amount: 40.33},
            ],
            outputs: [
              %{addr: "pid", txoid: "aaaa", amount: 100.00},
              %{addr: "pid", txoid: "aaaab", amount: 10.00}
            ]
        }
        
        block = first_block |> Block.initialize() |> Block.add_transaction(tx)
        ground_truth = [
            %{addr: "pid", txoid: "aaaa", amount: 100.00},
            %{addr: "pid", txoid: "aaaab", amount: 10.00}
        ]
        assert ground_truth == Block.get_my_coins_from_block(block,"pid")
        
        
    end

end


