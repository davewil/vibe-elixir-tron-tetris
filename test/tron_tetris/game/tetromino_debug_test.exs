defmodule TronTetris.Game.TetrominoDebugTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Board
  test "debug i piece rotation coordinates" do
    # I piece at position 3,1
    tetromino = %{Tetromino.new(:i) | location: {3, 1}}

    # Create the board with obstacles
    board = %{Board.new() | landed_tetrominos: MapSet.new([{5, 1}, {6, 1}])}

    # Get the absolute coordinates at rotation 0
    coords_rot0 = Tetromino.to_absolute_coordinates(tetromino)
    IO.puts("I at rotation 0, position (3,1) has coordinates: #{inspect(coords_rot0)}")

    # Get the absolute coordinates at rotation 1
    rotated = %{tetromino | rotation: 1}
    coords_rot1 = Tetromino.to_absolute_coordinates(rotated)
    IO.puts("I at rotation 1, position (3,1) has coordinates: #{inspect(coords_rot1)}")

    # Check if rotated coordinates collide with the landed blocks
    collides = Enum.any?(coords_rot1, fn point -> MapSet.member?(board.landed_tetrominos, point) end)
    IO.puts("Does rotation 1 collide with landed blocks? #{collides}")

    # Test the board's valid_position function
    is_valid_rot0 = Board.valid_position?(tetromino, board)
    is_valid_rot1 = Board.valid_position?(rotated, board)

    IO.puts("Is rotation 0 valid? #{is_valid_rot0}")
    IO.puts("Is rotation 1 valid? #{is_valid_rot1}")

    # Test the actual rotate function
    board = %{board | active_tetromino: tetromino}
    rotated_board = Board.rotate(board)
    IO.puts("After rotate: rotation=#{rotated_board.active_tetromino.rotation}")
  end
end
