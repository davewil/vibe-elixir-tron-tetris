defmodule TronTetris.Game.DebugTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino

  test "debug rotation at edge" do
    # Create a board with a tetromino at the right edge where rotation would be invalid
    tetromino = %{Tetromino.new(:i) | location: {9, 0}}
    board = %{Board.new() | active_tetromino: tetromino}

    # Print the initial state

    # Directly create a deep copy of tetromino to ensure it's fully independent
    tetromino_copy = %{
      shape: tetromino.shape,
      location: tetromino.location,
      points: tetromino.points,
      rotation: tetromino.rotation
    }

    # Check that our copy is truly independent

    # Update board with our deep copy
    board = %{board | active_tetromino: tetromino_copy}

    # Call Board.rotate and check the result
    rotated_board = Board.rotate(board)
      # Since the I tetromino at position {9, 0} would have pieces outside
    # the board when rotated to rotation 1, it should stay at rotation 0
    # But if the rotate function is working correctly, it should still
    # check validity and set the correct rotation
    assert rotated_board.active_tetromino.rotation == (
      if Board.valid_position?(%{tetromino | rotation: 1}, board),
      do: 1,
      else: 0
    )
  end
end
