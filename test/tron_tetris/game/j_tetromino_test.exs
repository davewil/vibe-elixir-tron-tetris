defmodule TronTetris.Game.JTetrominoTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "j tetromino rotation at various positions" do

    # Create a J tetromino at the default position
    tetromino = Tetromino.new(:j)

    # Print the base points

    # Check rotations
    for rotation <- 0..3 do
      rotated = %{tetromino | rotation: rotation}
      coords = Tetromino.to_absolute_coordinates(rotated)
    end

    # Try with a position that might cause boundary issues
    tetromino = %{Tetromino.new(:j) | location: {9, 18}}

    # Get coordinates for various rotations
    for rotation <- 0..3 do
      rotated = %{tetromino | rotation: rotation}
      coords = Tetromino.to_absolute_coordinates(rotated)

      # Check if any are outside the boundaries
      board_width = 10
      board_height = 20
      outside = Enum.filter(coords, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)


      # Check validity
      board = %{Board.new() | active_tetromino: tetromino}
      is_valid = Board.valid_position?(rotated, board)
    end
  end
end
