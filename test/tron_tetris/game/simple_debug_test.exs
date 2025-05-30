defmodule TronTetris.Game.SimpleDebugTest do
  use ExUnit.Case, async: true

  test "debug print" do
    IO.puts("This is a debug print test")
    assert true
  end
end
