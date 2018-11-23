defmodule Utiltest do
    use ExUnit.case
    doctest Util

    test "gives correct hash" do
        assert Util.get_hex_sha256_hash("Bitcoin") == "b4056df6691f8dc72e56302ddad345d65fead3ead9299609a826e2344eb63aa4"
    end

    
end