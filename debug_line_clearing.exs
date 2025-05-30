# Test line clearing functionality step by step

IO.puts("=== Testing Line Clearing ===")

# Test 1: Basic line clearing
IO.puts("\n1. Testing basic line clearing...")
board = TronTetris.Game.Board.new()
landed_points = for x <- 0..9, do: {x, 19}
landed_set = MapSet.new(landed_points)
{new_landed, lines_cleared} = TronTetris.Game.Board.clear_lines(landed_set, 20, 10)
IO.puts("Lines cleared: #{lines_cleared}")
IO.puts("Remaining blocks: #{MapSet.size(new_landed)}")
IO.puts("New landed: #{inspect(MapSet.to_list(new_landed))}")

# Test 2: Line clearing through land_tetromino
IO.puts("\n2. Testing line clearing through land_tetromino...")
board = TronTetris.Game.Board.new()
# Create a nearly complete row
landed_points = for x <- 0..8, do: {x, 19}
landed_set = MapSet.new(landed_points)
board_with_nearly_complete_row = %{board | landed_tetrominos: landed_set}

# Create a tetromino that will complete the row when landed
completing_tetromino = %{
  shape: :o,
  points: [{0, 0}],  # Just a single block
  location: {9, 19},
  rotation: 0
}

board_ready_to_clear = %{board_with_nearly_complete_row | active_tetromino: completing_tetromino}

IO.puts("Before landing:")
IO.puts("Landed tetrominos count: #{MapSet.size(board_ready_to_clear.landed_tetrominos)}")
IO.puts("Active tetromino location: #{inspect(board_ready_to_clear.active_tetromino.location)}")

# Land the tetromino to trigger line clearing
result_board = TronTetris.Game.Board.land_tetromino(board_ready_to_clear)

IO.puts("\nAfter landing:")
IO.puts("Landed tetrominos count: #{MapSet.size(result_board.landed_tetrominos)}")
IO.puts("Landed tetrominos: #{inspect(MapSet.to_list(result_board.landed_tetrominos))}")
IO.puts("Lines cleared: #{result_board.lines_cleared}")
IO.puts("Score: #{result_board.score}")

# Check if row 19 still has any blocks
row_19_blocks = Enum.filter(MapSet.to_list(result_board.landed_tetrominos), fn {_x, y} -> y == 19 end)
IO.puts("Blocks remaining in row 19: #{inspect(row_19_blocks)}")
IO.puts("Should be empty: #{Enum.empty?(row_19_blocks)}")

# Test 3: Test actual game flow with drop
IO.puts("\n3. Testing with actual game drop flow...")
board = TronTetris.Game.Board.new()
# Create a nearly complete row
landed_points = for x <- 0..8, do: {x, 19}
landed_set = MapSet.new(landed_points)
board_with_nearly_complete_row = %{board | landed_tetrominos: landed_set}

# Move the active tetromino to the missing position
original_tetromino = board_with_nearly_complete_row.active_tetromino
moved_tetromino = %{original_tetromino | location: {9, 18}}
board_with_moved_piece = %{board_with_nearly_complete_row | active_tetromino: moved_tetromino}

IO.puts("Before drop:")
IO.puts("Landed tetrominos count: #{MapSet.size(board_with_moved_piece.landed_tetrominos)}")
IO.puts("Active tetromino location: #{inspect(board_with_moved_piece.active_tetromino.location)}")

# Drop the piece to complete the line
result_board = TronTetris.Game.Board.drop(board_with_moved_piece)

IO.puts("\nAfter drop:")
IO.puts("Landed tetrominos count: #{MapSet.size(result_board.landed_tetrominos)}")
IO.puts("Lines cleared: #{result_board.lines_cleared}")
IO.puts("Score: #{result_board.score}")

# Check if row 19 still has any blocks
row_19_blocks = Enum.filter(MapSet.to_list(result_board.landed_tetrominos), fn {_x, y} -> y == 19 end)
IO.puts("Blocks remaining in row 19: #{inspect(row_19_blocks)}")
IO.puts("Should be empty: #{Enum.empty?(row_19_blocks)}")

IO.puts("\n=== Test Complete ===")
