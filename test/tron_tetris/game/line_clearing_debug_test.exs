defmodule TronTetris.Game.LineClearingDebugTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino

  test "debug hard drop and line clearing with correct setup" do
    # Create a board with 6 blocks in bottom row, leaving space for 4-block I piece
    board = Board.new()
    # Fill positions 0-5 in row 19, leaving 6,7,8,9 empty for the I tetromino
    landed_points = for x <- 0..5, do: {x, 19}

    board_with_almost_full = %{board |
      landed_tetrominos: MapSet.new(landed_points),
      active_tetromino: %{Tetromino.new(:i) | location: {6, 15}, rotation: 0}
    }

    IO.puts("Before hard drop - landed points: #{MapSet.size(board_with_almost_full.landed_tetrominos)}")
    IO.puts("Before hard drop - lines cleared: #{board_with_almost_full.lines_cleared}")
    IO.puts("Existing blocks positions: #{inspect(Enum.to_list(board_with_almost_full.landed_tetrominos))}")

    # Check where the tetromino will land
    i_tetromino = %{Tetromino.new(:i) | location: {6, 15}, rotation: 0}
    dropped_position = find_landing_position_test(i_tetromino, board_with_almost_full)
    IO.puts("Final landing position would be: #{inspect(dropped_position)}")

    final_tetromino = %{i_tetromino | location: {elem(i_tetromino.location, 0), dropped_position}}
    final_points = Tetromino.to_absolute_coordinates(final_tetromino)
    IO.puts("Final tetromino points: #{inspect(final_points)}")

    # Perform hard drop
    dropped_board = Board.hard_drop(board_with_almost_full)

    IO.puts("After hard drop - landed points: #{MapSet.size(dropped_board.landed_tetrominos)}")
    IO.puts("After hard drop - lines cleared: #{dropped_board.lines_cleared}")
    IO.puts("After hard drop - score: #{dropped_board.score}")
    IO.puts("After hard drop - game over: #{dropped_board.game_over}")

    # Verify line was cleared
    assert dropped_board.lines_cleared > 0
  end

  # Helper function to test landing position calculation
  defp find_landing_position_test(tetromino, board) do
    curr_y = elem(tetromino.location, 1)
    curr_x = elem(tetromino.location, 0)

    # Try each position down until we hit an invalid one
    Stream.iterate(curr_y, &(&1 + 1))
    |> Stream.take(board.height)
    |> Enum.reduce_while(curr_y, fn y, last_valid_y ->
      test_tetromino = %{tetromino | location: {curr_x, y}}
      if Board.valid_position?(test_tetromino, board) do
        {:cont, y}  # Keep going down
      else
        {:halt, last_valid_y}  # Stop at the last valid position
      end
    end)
  end
end
