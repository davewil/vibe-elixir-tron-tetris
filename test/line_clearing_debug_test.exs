defmodule LineClearing.TestDebug do
  use ExUnit.Case
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino

  test "line clearing functionality" do
    IO.puts("\n=== Testing Line Clearing ===")

    # Test clear_lines directly
    IO.puts("Testing clear_lines directly:")
    test_landed = MapSet.new([{0, 19}, {1, 19}, {2, 19}, {3, 19}, {4, 19}, {5, 19}, {6, 19}, {7, 19}, {8, 19}, {9, 19}])
    {cleared_landed, lines_cleared} = Board.clear_lines(test_landed, 20, 10)
    IO.puts("  Original: #{inspect(MapSet.to_list(test_landed))}")
    IO.puts("  After clear_lines: #{inspect(MapSet.to_list(cleared_landed))}")
    IO.puts("  Lines cleared: #{lines_cleared}")

    assert lines_cleared == 1
    assert MapSet.size(cleared_landed) == 0

    # Test land_tetromino with line clearing
    IO.puts("\nTesting land_tetromino with line clearing:")
    board = Board.new()

    # Add 9 blocks in the bottom row (19)
    landed_points = for x <- 0..8, do: {x, 19}
    landed_set = MapSet.new(landed_points)
    board = %{board | landed_tetrominos: landed_set}

    IO.puts("Board with 9 blocks in bottom row: #{inspect(MapSet.to_list(board.landed_tetrominos))}")

    # Create a tetromino that will complete the row when landed
    completing_tetromino = %{
      shape: :o,
      points: [{0, 0}],  # Just a single block
      location: {9, 19},
      rotation: 0
    }
    board = %{board | active_tetromino: completing_tetromino}

    IO.puts("Before landing tetromino:")
    IO.puts("  Active tetromino: #{inspect(board.active_tetromino)}")
    IO.puts("  Landed blocks: #{inspect(MapSet.to_list(board.landed_tetrominos))}")
    IO.puts("  Lines cleared so far: #{board.lines_cleared}")
    IO.puts("  Score: #{board.score}")

    # Land the tetromino
    new_board = Board.land_tetromino(board)

    IO.puts("\nAfter landing tetromino:")
    IO.puts("  Active tetromino: #{inspect(new_board.active_tetromino)}")
    IO.puts("  Landed blocks: #{inspect(MapSet.to_list(new_board.landed_tetrominos))}")
    IO.puts("  Lines cleared: #{new_board.lines_cleared}")
    IO.puts("  Score: #{new_board.score}")

    # Verify the line was cleared
    assert new_board.lines_cleared == 1
    assert new_board.score > 0

    # The bottom row should be empty (all blocks cleared)
    bottom_row_blocks = Enum.filter(new_board.landed_tetrominos, fn {_x, y} -> y == 19 end)
    assert Enum.empty?(bottom_row_blocks), "Bottom row should be empty after clearing"

    IO.puts("\n=== Line Clearing Test Complete ===")
  end
end
