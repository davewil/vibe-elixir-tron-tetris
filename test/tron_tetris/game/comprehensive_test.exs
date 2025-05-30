defmodule TronTetris.Game.ComprehensiveTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino
  
  test "rotation_invalid_position" do
    # Create a situation where a J tetromino can't rotate because it would go out of bounds
    tetromino = %{Tetromino.new(:j) | location: {9, 18}}

    # Create a board with the tetromino
    board = %{
      Board.new() |
      active_tetromino: tetromino
    }

    # Manually confirm rotation would be invalid
    rotated_test = %{tetromino | rotation: 1}
    refute Board.valid_position?(rotated_test, board)

    # Call the rotate function
    rotated_board = Board.rotate(board)

    # Check that nothing changed
    assert rotated_board.active_tetromino.rotation == 0
    assert rotated_board.active_tetromino.location == tetromino.location
  end
  test "rotation_collision_with_landed_blocks" do
    # Create a situation where rotation would cause collision with landed blocks
    # Position the I piece horizontally with blocks in the path of its vertical rotation
    landed_blocks = [{3, 2}, {3, 3}, {3, 4}] |> MapSet.new()
    tetromino = %{Tetromino.new(:i) | location: {3, 1}}
    
    # Create a board with the tetromino and landed blocks
    board = %{
      Board.new() |
      active_tetromino: tetromino,
      landed_tetrominos: landed_blocks
    }
      # Create a rotated version of the tetromino for testing
    rotated_test = %{tetromino | rotation: 1}
    _rotated_coords = Tetromino.to_absolute_coordinates(rotated_test) # Kept for debugging if needed
      # Confirm horizontal tetromino position is valid but rotation would be invalid
    assert Board.valid_position?(tetromino, board)
    refute Board.valid_position?(rotated_test, board)
    
    # Call the rotate function
    rotated_board = Board.rotate(board)
    
    # Check that nothing changed - rotation is still 0
    assert rotated_board.active_tetromino.rotation == 0
    assert rotated_board.active_tetromino.location == tetromino.location
  end
end
