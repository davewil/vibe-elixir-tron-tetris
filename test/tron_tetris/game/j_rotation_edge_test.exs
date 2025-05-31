defmodule TronTetris.Game.JRotationEdgeTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "j tetromino rotation at edge" do

    # Create a J tetromino at the edge position
    tetromino = %{Tetromino.new(:j) | location: {9, 18}}

    # Get coordinates for rotation 0 and 1
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    rotated = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(rotated)


    # Check if any points go outside the board
    board_width = 10
    board_height = 20

    rot0_outside = Enum.filter(coords_rot0, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)
    rot1_outside = Enum.filter(coords_rot1, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)


    # Create a board with tetromino
    board = %{Board.new() | active_tetromino: tetromino}

    # Check valid position
    is_valid_rot0 = Board.valid_position?(tetromino, board)
    is_valid_rot1 = Board.valid_position?(rotated, board)


    # Test the rotate function
    rotated_board = Board.rotate(board)
  end
end
