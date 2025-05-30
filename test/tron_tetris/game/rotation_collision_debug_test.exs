defmodule TronTetris.Game.RotationCollisionDebugTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "debug rotation collision at position 5,2 with landed blocks" do
    IO.puts("Starting debug test")
    # The landed blocks from the failing test
    landed_blocks = [{6, 1}, {6, 2}, {6, 3}] |> MapSet.new()
    IO.puts("Landed blocks: #{inspect(MapSet.to_list(landed_blocks))}")

    # Create the I tetromino in the position from the test
    tetromino = %{Tetromino.new(:i) | location: {5, 2}}

    # Get the absolute coordinates at rotation 0 (horizontal)
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    IO.puts("I at rotation 0, position (5,2) has coordinates: #{inspect(coords_rot0)}")

    # Get the absolute coordinates at rotation 1 (vertical)
    rotated = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(rotated)
    IO.puts("I at rotation 1, position (5,2) has coordinates: #{inspect(coords_rot1)}")

    # Check if the rotated tetromino collides with any landed blocks
    rotation_0_collisions = Enum.filter(coords_rot0, fn point -> MapSet.member?(landed_blocks, point) end)
    rotation_1_collisions = Enum.filter(coords_rot1, fn point -> MapSet.member?(landed_blocks, point) end)

    IO.puts("Rotation 0 collisions with landed blocks: #{inspect(rotation_0_collisions)}")
    IO.puts("Rotation 1 collisions with landed blocks: #{inspect(rotation_1_collisions)}")

    # Create a board with these elements
    board = %{
      Board.new() |
      active_tetromino: tetromino,
      landed_tetrominos: landed_blocks
    }

    # Test the valid_position function
    is_valid_rot0 = Board.valid_position?(tetromino, board)
    is_valid_rot1 = Board.valid_position?(rotated, board)

    IO.puts("Is rotation 0 valid? #{is_valid_rot0}")
    IO.puts("Is rotation 1 valid? #{is_valid_rot1}")

    # Test if specific points collide
    for x <- 5..8, y <- 1..3 do
      point = {x, y}
      in_landed = MapSet.member?(landed_blocks, point)
      in_rot0 = Enum.member?(coords_rot0, point)
      in_rot1 = Enum.member?(coords_rot1, point)

      if in_landed || in_rot0 || in_rot1 do
        IO.puts("Point #{inspect(point)}: in_landed=#{in_landed}, in_rot0=#{in_rot0}, in_rot1=#{in_rot1}")
      end
    end
  end
end
