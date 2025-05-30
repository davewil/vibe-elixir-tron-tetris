defmodule TronTetris.Game.IntegrationTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Board
  alias TronTetris.Game.Tetromino
  alias TronTetris.Game.Server
  alias TronTetris.Game.Supervisor

  describe "game lifecycle integration" do
    setup do
      # Create unique player id for this test
      player_id = "test_player_#{:erlang.unique_integer([:positive])}"

      # Start a supervisor for this test
      {:ok, _pid} = start_supervised({Registry, keys: :unique, name: TestRegistry})
      {:ok, _pid} = start_supervised({DynamicSupervisor, strategy: :one_for_one, name: TestSupervisor})

      # Mock the server_name function for the tests
      server_name_fn = fn id -> {:via, Registry, {TestRegistry, id}} end

      %{player_id: player_id, server_name_fn: server_name_fn}
    end

    test "full game lifecycle with level progression", %{player_id: player_id, server_name_fn: server_name_fn} do
      # Start a new game
      child_spec = %{
        id: Server,
        start: {Server, :start_link, [[name: server_name_fn.(player_id), player_id: player_id]]},
        restart: :temporary
      }

      {:ok, _pid} = DynamicSupervisor.start_child(TestSupervisor, child_spec)
      server = server_name_fn.(player_id)

      # Get initial state
      {board, paused} = Server.get_state(server)
      assert paused == false
      assert board.level == 1
      assert board.score == 0
      assert board.lines_cleared == 0

      # Simulate dropping pieces to create completed lines
      # We'll use a custom board to test line clearing and scoring
      board_with_almost_full_line = create_board_with_almost_full_line()
      Server.load_game(server, board_with_almost_full_line)

      # Add the missing piece in the right position to complete the line
      Server.toggle_pause(server) # Unpause first
      position_piece_to_complete_line(server)
      Server.hard_drop(server)

      # Check that the line was cleared and score was updated
      {board_after_line_clear, _} = Server.get_state(server)
      assert board_after_line_clear.lines_cleared > 0
      assert board_after_line_clear.score > 0

      # Test game over condition
      board_almost_game_over = create_board_almost_game_over()
      Server.load_game(server, board_almost_game_over)
      Server.toggle_pause(server)

      # Force game over with one more piece
      position_piece_for_game_over(server)
      Server.hard_drop(server)

      # Check game over condition
      {board_game_over, _} = Server.get_state(server)
      assert board_game_over.game_over == true

      # Test restarting after game over
      Server.new_game(server)
      {board_new, _} = Server.get_state(server)
      assert board_new.game_over == false
      assert board_new.score == 0
    end
  end
  # Helper functions to create specific board states
  defp create_board_with_almost_full_line do
    # Create a board with 6 out of 10 blocks filled in the bottom row (leaving space for 4-block I piece)
    board = Board.new()
    # Fill positions 0-5 in row 19 (leaving positions 6-9 empty for the I tetromino)
    landed_points = for x <- 0..5, do: {x, 19}

    # Use an I tetromino (4 blocks wide) that will complete the line when placed properly
    # Starting position needs to align with the right edge when dropped
    %{board |
      landed_tetrominos: MapSet.new(landed_points),
      # Position the I tetromino so it will complete the line when dropped
      active_tetromino: %{Tetromino.new(:i) | location: {6, 15}, rotation: 0}, # Horizontal I piece (rotation 0)
      next_tetromino: Tetromino.new(:o) # Next piece is predictable
    }
  end
  defp position_piece_to_complete_line(server) do
    # Move piece so that it will complete the line when dropped
    # First get current position
    {board, _} = Server.get_state(server)
    current_pos = board.active_tetromino.location

    # For an I tetromino in horizontal position (rotation=0), it spans 4 cells
    # We want the rightmost block to be at x=9 when dropped to y=19
    # So for a 4-wide piece, the leftmost block should be at x=6
    target_x = 6

    # Calculate moves to reach the target position
    moves_right = target_x - elem(current_pos, 0)

    IO.puts("Current position: #{inspect(current_pos)}, Target X: #{target_x}, Moves right: #{moves_right}")

    if moves_right < 0 do
      # Need to move left
      Enum.each(1..abs(moves_right), fn _ ->
        Server.move_left(server)
        Process.sleep(10)
      end)
    else
      # Need to move right
      Enum.each(1..moves_right, fn _ ->
        Server.move_right(server)
        Process.sleep(10)
      end)
    end

    # Make sure piece is horizontal to complete the line
    {board_after_move, _} = Server.get_state(server)
    if board_after_move.active_tetromino.rotation != 0 do
      # Rotate until we get to rotation=0 (horizontal)
      # Define a named function for recursion
      rotation_loop = fn
        rotation, rotation_fn ->
          case rotation do
            0 -> :ok
            _ ->
              Server.rotate(server)
              Process.sleep(10)
              {b, _} = Server.get_state(server)
              rotation_fn.(b.active_tetromino.rotation, rotation_fn)
          end
      end

      rotation_loop.(board_after_move.active_tetromino.rotation, rotation_loop)
    end
      # Log final position for debugging
    {board_final, _} = Server.get_state(server)
    IO.puts("Final position before drop: #{inspect(board_final.active_tetromino.location)}, rotation: #{board_final.active_tetromino.rotation}")
  end

  defp create_board_almost_game_over do
    # Create a board with blocks stacked high, close to game over
    board = Board.new()
      # Fill most of the board but leave row 0 mostly empty except for the spawn location
    # Fill rows 2-19, and add a block at the spawn location {4, 0}
    landed_points = for y <- 2..19, x <- 0..9, do: {x, y}
      # Add a block specifically at the spawn location to trigger game over
    spawn_blocking_points = [{4, 0}]
    all_points = landed_points ++ spawn_blocking_points

    %{board |
      landed_tetrominos: MapSet.new(all_points),
      # Use a simple O tetromino that won't clear lines when dropped
      active_tetromino: %{Tetromino.new(:o) | location: {6, 0}, rotation: 0}  # O piece at {6, 0}
    }
  end

  defp position_piece_for_game_over(_server) do
    # The O tetromino is already positioned to cause game over when dropped
    # When it lands, the next tetromino won't be able to spawn at {4, 0} because it's blocked
    # No movement needed - the piece is already positioned correctly
    :ok
  end
end
