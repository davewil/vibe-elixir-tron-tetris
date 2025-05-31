defmodule TronTetris.Game.GameOverDebugTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino
  test "debug game over condition" do
    # Recreate the NEW scenario from the integration test
    board = Board.new()

    # Fill most of the board but leave the spawn area (around {4,0}) specifically problematic
    # Fill rows 1-19, leaving only row 0 mostly empty but with blocks at the spawn location
    landed_points = for y <- 1..19, x <- 0..9, do: {x, y}

    # Add a block specifically at the spawn location to trigger game over
    spawn_blocking_points = [{4, 0}]

    all_points = landed_points ++ spawn_blocking_points

    board_with_blocks = %{board |
      landed_tetrominos: MapSet.new(all_points),
      # Use a simple O tetromino that won't clear lines when dropped
      active_tetromino: %{Tetromino.new(:o) | location: {0, 0}, rotation: 0}  # O piece at top left
    }


    # Check if the active tetromino is in a valid position
    is_valid = Board.valid_position?(board_with_blocks.active_tetromino, board_with_blocks)
    coords = Tetromino.to_absolute_coordinates(board_with_blocks.active_tetromino)

    # Check if any of these coordinates conflict with landed blocks
    conflicts = Enum.filter(coords, fn coord -> MapSet.member?(board_with_blocks.landed_tetrominos, coord) end)

    # Check the bounds
    out_of_bounds = Enum.filter(coords, fn {x, y} -> x < 0 || x >= 10 || y < 0 || y >= 20 end)

    # Check what's at the spawn location {4, 0}
    spawn_blocked = MapSet.member?(board_with_blocks.landed_tetrominos, {4, 0})

    # Try hard dropping the piece
    dropped_board = Board.hard_drop(board_with_blocks)

    # If not game over, check the new tetromino's validity
    if not dropped_board.game_over do
      new_tetromino_valid = Board.valid_position?(dropped_board.active_tetromino, dropped_board)
      new_coords = Tetromino.to_absolute_coordinates(dropped_board.active_tetromino)
    end
  end
end
