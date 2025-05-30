defmodule TronTetris.Game.BoundaryDebugTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "i tetromino at far right edge" do
    # Create an "I" tetromino at the far right edge (x=9)
    tetromino = %{Tetromino.new(:i) | location: {9, 5}}

    # Get points for rotation 0
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    IO.puts("I at position (9,5) with rotation 0 has coordinates: #{inspect(coords_rot0)}")

    # Get points for rotation 1 (vertical I)
    tetromino1 = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(tetromino1)
    IO.puts("I at position (9,5) with rotation 1 has coordinates: #{inspect(coords_rot1)}")

    # Create a board and check if rotation would be valid
    board = Board.new()
    valid0 = Board.valid_position?(tetromino, board)
    valid1 = Board.valid_position?(tetromino1, board)

    IO.puts("Rotation 0 valid? #{valid0}")
    IO.puts("Rotation 1 valid? #{valid1}")

    # Add the tetromino to the board and test rotating
    board = %{board | active_tetromino: tetromino}
    rotated_board = Board.rotate(board)

    IO.puts("Original rotation: #{tetromino.rotation}")
    IO.puts("Rotated board rotation: #{rotated_board.active_tetromino.rotation}")

    # Test if the "I" piece at far-right edge can actually be placed on the board
    i_at_edge = %{Tetromino.new(:i) | location: {9, 5}}
    is_valid = Board.valid_position?(i_at_edge, Board.new())
    IO.puts("I at (9,5) valid? #{is_valid}")
  end
end
