defmodule LineTest do
  def test_line_clearing do
    board = TronTetris.Game.Board.new()

    # Create a board with a nearly complete row (9 out of 10 blocks in row 19)
    landed_points = for x <- 0..8, do: {x, 19}
    landed_set = MapSet.new(landed_points)
    board_with_nearly_complete_row = %{board | landed_tetrominos: landed_set}

    IO.puts("Before line clearing:")
    IO.puts("Landed tetrominos count: #{MapSet.size(board_with_nearly_complete_row.landed_tetrominos)}")
    IO.puts("Landed tetrominos: #{inspect(MapSet.to_list(board_with_nearly_complete_row.landed_tetrominos))}")

    # Create a tetromino that will complete the row when landed
    completing_tetromino = %{
      shape: :o,
      points: [{0, 0}],  # Just a single block
      location: {9, 19},
      rotation: 0
    }

    board_ready_to_clear = %{board_with_nearly_complete_row | active_tetromino: completing_tetromino}

    # Land the tetromino to trigger line clearing
    result_board = TronTetris.Game.Board.land_tetromino(board_ready_to_clear)

    IO.puts("\nAfter line clearing:")
    IO.puts("Landed tetrominos count: #{MapSet.size(result_board.landed_tetrominos)}")
    IO.puts("Landed tetrominos: #{inspect(MapSet.to_list(result_board.landed_tetrominos))}")
    IO.puts("Lines cleared: #{result_board.lines_cleared}")
    IO.puts("Score: #{result_board.score}")

    # Check if row 19 still has any blocks
    row_19_blocks = Enum.filter(MapSet.to_list(result_board.landed_tetrominos), fn {_x, y} -> y == 19 end)
    IO.puts("Blocks remaining in row 19: #{inspect(row_19_blocks)}")
  end
end

LineTest.test_line_clearing()
