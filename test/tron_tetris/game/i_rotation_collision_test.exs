defmodule TronTetris.Game.IRotationCollisionTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "debug I tetromino rotation with collision" do
      # Create a scenario with landed blocks that would block rotation
    landed_blocks = [{3, 2}, {3, 3}, {3, 4}] |> MapSet.new()
    tetromino = %{Tetromino.new(:i) | location: {3, 1}}

    # Get coordinates for rotations
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    rotated = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(rotated)


    # Create a board with tetromino and check validity
    board = %{
      Board.new() |
      active_tetromino: tetromino,
      landed_tetrominos: landed_blocks
    }


    # Check if any of the rotated coordinates collide with landed blocks
    rot0_collisions = Enum.filter(coords_rot0, fn point -> MapSet.member?(landed_blocks, point) end)
    rot1_collisions = Enum.filter(coords_rot1, fn point -> MapSet.member?(landed_blocks, point) end)


    # Check validity using Board functions
    is_valid_rot0 = Board.valid_position?(tetromino, board)
    is_valid_rot1 = Board.valid_position?(rotated, board)


    # Test the rotate function
    rotated_board = Board.rotate(board)

    # The meaningful assertion to confirm behavior
    assert rotated_board.active_tetromino.rotation ==
           (if is_valid_rot1, do: 1, else: 0)
  end
end
