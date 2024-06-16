defmodule KvServer.CommandTest do
  use ExUnit.Case

  alias KvServer.Command

  @valid_commands [
    "CREATE shopping",
    "PUT shopping milk 3",
    "GET shopping milk",
    "DELETE shoppig milk"
  ]

  describe "parse/1" do
    for line <- @valid_commands do
      test "parses #{line}" do
        assert {:ok, _} = Command.parse(unquote(line))
      end
    end

    test "returns error with invalid command" do
      assert {:error, _} = Command.parse("invalid command")
    end
  end
end
