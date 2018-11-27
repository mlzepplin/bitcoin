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

end


