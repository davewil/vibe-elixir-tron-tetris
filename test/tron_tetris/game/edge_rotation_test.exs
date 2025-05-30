defmodule TronTetris.Game.EdgeRotationTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board

  test "i tetromino at position 8,2 rotation test" do
    IO.puts("Starting edge rotation test")
    # Create an I tetromino at position (8,2)
    tetromino = %{Tetromino.new(:i) | location: {8, 2}}

    # Get coordinates for rotation 0 and 1
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    rotated = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(rotated)

    IO.puts("I at rotation 0, position (8,2) has coordinates: #{inspect(coords_rot0)}")
    IO.puts("I at rotation 1, position (8,2) has coordinates: #{inspect(coords_rot1)}")

    # Check if any points go outside the board
    board_width = 10
    board_height = 20

    rot0_outside = Enum.filter(coords_rot0, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)
    rot1_outside = Enum.filter(coords_rot1, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)

    IO.puts("Rotation 0 points outside board: #{inspect(rot0_outside)}")
    IO.puts("Rotation 1 points outside board: #{inspect(rot1_outside)}")

    # Check position validity using the board functions
    board = Board.new()
    board = %{board | active_tetromino: tetromino}

    is_valid_rot0 = Board.valid_position?(tetromino, board)
    is_valid_rot1 = Board.valid_position?(rotated, board)

    IO.puts("Is rotation 0 valid? #{is_valid_rot0}")
    IO.puts("Is rotation 1 valid? #{is_valid_rot1}")

    # Test with position 9,2 as well for edge case
    tetromino2 = %{Tetromino.new(:i) | location: {9, 2}}
    coords_rot0_2 = Tetromino.to_absolute_coordinates(tetromino2)
    rotated2 = %{tetromino2 | rotation: 1}
    coords_rot1_2 = Tetromino.to_absolute_coordinates(rotated2)

    IO.puts("\nI at rotation 0, position (9,2) has coordinates: #{inspect(coords_rot0_2)}")
    IO.puts("I at rotation 1, position (9,2) has coordinates: #{inspect(coords_rot1_2)}")

    # Check if any points go outside the board
    rot0_outside_2 = Enum.filter(coords_rot0_2, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)
    rot1_outside_2 = Enum.filter(coords_rot1_2, fn {x, y} -> x < 0 || x >= board_width || y < 0 || y >= board_height end)

    IO.puts("Rotation 0 points outside board: #{inspect(rot0_outside_2)}")
    IO.puts("Rotation 1 points outside board: #{inspect(rot1_outside_2)}")

    board2 = %{Board.new() | active_tetromino: tetromino2}
    is_valid_rot0_2 = Board.valid_position?(tetromino2, board2)
    is_valid_rot1_2 = Board.valid_position?(rotated2, board2)

    IO.puts("Is rotation 0 valid? #{is_valid_rot0_2}")
    IO.puts("Is rotation 1 valid? #{is_valid_rot1_2}")
  end
end
