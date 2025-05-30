defmodule TronTetris.Game.IRotationCollisionTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "debug I tetromino rotation with collision" do
    IO.puts("\n>>>>>>> STARTING COLLISION TEST <<<<<<<<")
    IO.puts("Testing I tetromino rotation with collision")
      # Create a scenario with landed blocks that would block rotation
    landed_blocks = [{3, 2}, {3, 3}, {3, 4}] |> MapSet.new()
    tetromino = %{Tetromino.new(:i) | location: {3, 1}}

    # Get coordinates for rotations
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    rotated = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(rotated)

    IO.puts("I at rotation 0, position (3,1) has coordinates: #{inspect(coords_rot0)}")
    IO.puts("I at rotation 1, position (3,1) has coordinates: #{inspect(coords_rot1)}")

    # Create a board with tetromino and check validity
    board = %{
      Board.new() |
      active_tetromino: tetromino,
      landed_tetrominos: landed_blocks
    }

    IO.puts("Landed blocks: #{inspect(MapSet.to_list(landed_blocks))}")

    # Check if any of the rotated coordinates collide with landed blocks
    rot0_collisions = Enum.filter(coords_rot0, fn point -> MapSet.member?(landed_blocks, point) end)
    rot1_collisions = Enum.filter(coords_rot1, fn point -> MapSet.member?(landed_blocks, point) end)

    IO.puts("Rotation 0 collisions: #{inspect(rot0_collisions)}")
    IO.puts("Rotation 1 collisions: #{inspect(rot1_collisions)}")

    # Check validity using Board functions
    is_valid_rot0 = Board.valid_position?(tetromino, board)
    is_valid_rot1 = Board.valid_position?(rotated, board)

    IO.puts("Is rotation 0 valid? #{is_valid_rot0}")
    IO.puts("Is rotation 1 valid? #{is_valid_rot1}")

    # Test the rotate function
    rotated_board = Board.rotate(board)
    IO.puts("After rotate, rotation: #{rotated_board.active_tetromino.rotation}")

    # The meaningful assertion to confirm behavior
    assert rotated_board.active_tetromino.rotation ==
           (if is_valid_rot1, do: 1, else: 0)
  end
end
