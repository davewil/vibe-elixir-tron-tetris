defmodule TronTetris.Game.ServerTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Server
  alias TronTetris.Game.Board  # Mock PubSub setup - we'll use this to test broadcasts
  setup do
    test_pid = self()
    
    # Create a more robust mock setup
    mock_setup = try do
      # Check if already mocked
      case :meck.validate(Phoenix.PubSub) do
        true -> 
          # Already mocked, just update expectation
          :meck.expect(Phoenix.PubSub, :broadcast, 
            fn _pubsub, _topic, message -> 
              send(test_pid, {:pubsub_broadcast, message})
              :ok
            end)
          :existing_mock
        false ->
          # Not mocked, create new mock
          :meck.new(Phoenix.PubSub, [:passthrough])
          :meck.expect(Phoenix.PubSub, :broadcast, 
            fn _pubsub, _topic, message -> 
              send(test_pid, {:pubsub_broadcast, message})
              :ok
            end)
          :new_mock
      end
    catch
      :error, {:not_mocked, _} ->
        # Module not mocked, create new mock
        :meck.new(Phoenix.PubSub, [:passthrough])
        :meck.expect(Phoenix.PubSub, :broadcast, 
          fn _pubsub, _topic, message -> 
            send(test_pid, {:pubsub_broadcast, message})
            :ok
          end)
        :new_mock
      :error, {:already_started, _} ->
        # Mock already started, just proceed
        :existing_mock
    end
    
    # Cleanup after test
    on_exit(fn -> 
      if mock_setup == :new_mock do
        try do
          :meck.unload(Phoenix.PubSub)
        catch
          _, _ -> :ok
        end
      end
    end)
    
    # Start a test game server with unique name to avoid conflicts
    server_name = :"game_server_#{:erlang.unique_integer([:positive])}"
    player_id = "test_player_#{:erlang.unique_integer([:positive])}"
    {:ok, server_pid} = Server.start_link(name: server_name, player_id: player_id)
    
    %{server: server_name, server_pid: server_pid, player_id: player_id}
  end

  describe "start_link/1" do
    test "starts a new game server with default values", %{server_pid: pid} do
      assert Process.alive?(pid)
    end
  end
  describe "get_state/1" do
    test "returns the current board and paused state", %{server: server} do
      {board, paused} = Server.get_state(server)
      
      assert is_map(board)
      assert Map.has_key?(board, :active_tetromino)
      assert paused == false
    end
  end

  describe "new_game/2" do
    test "creates a new game board with the specified difficulty", %{server: server} do
      board = Server.new_game(server, :hard)
      
      assert board.difficulty == :hard
      assert board.score == 0
      assert board.level == 1
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, ^board}}
    end
  end

  describe "toggle_pause/1" do
    test "toggles the paused state of the game", %{server: server} do
      # Initially not paused
      {_, paused} = Server.get_state(server)
      assert paused == false
      
      # Pause the game
      Server.toggle_pause(server)
      Process.sleep(10)  # Give it time to process
      {_, paused} = Server.get_state(server)
      assert paused == true
      
      # Unpause the game
      Server.toggle_pause(server)
      Process.sleep(10)  # Give it time to process
      {_, paused} = Server.get_state(server)
      assert paused == false
    end
  end

  describe "movement commands" do
    test "move_left/1 updates the board when game is not paused", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_position = board_before.active_tetromino.location
      
      Server.move_left(server)
      Process.sleep(10)  # Give it time to process
      
      {board_after, _} = Server.get_state(server)
      new_position = board_after.active_tetromino.location
      
      # Position should move left (x decreases by 1)
      assert elem(new_position, 0) == elem(original_position, 0) - 1
      assert elem(new_position, 1) == elem(original_position, 1)
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
    
    test "move_right/1 updates the board when game is not paused", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_position = board_before.active_tetromino.location
      
      Server.move_right(server)
      Process.sleep(10)  # Give it time to process
      
      {board_after, _} = Server.get_state(server)
      new_position = board_after.active_tetromino.location
      
      # Position should move right (x increases by 1)
      assert elem(new_position, 0) == elem(original_position, 0) + 1
      assert elem(new_position, 1) == elem(original_position, 1)
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
    
    test "rotate/1 updates the tetromino rotation when game is not paused", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_rotation = board_before.active_tetromino.rotation
      
      Server.rotate(server)
      Process.sleep(10)  # Give it time to process
      
      {board_after, _} = Server.get_state(server)
      new_rotation = board_after.active_tetromino.rotation
      
      # Rotation should increase by 1
      assert new_rotation == rem(original_rotation + 1, 4)
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
    
    test "drop/1 moves the tetromino down when game is not paused", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_position = board_before.active_tetromino.location
      
      Server.drop(server)
      Process.sleep(10)  # Give it time to process
      
      {board_after, _} = Server.get_state(server)
      new_position = board_after.active_tetromino.location
      
      # Position should move down (y increases by 1)
      assert elem(new_position, 0) == elem(original_position, 0)
      assert elem(new_position, 1) == elem(original_position, 1) + 1
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
    
    test "hard_drop/1 drops the tetromino to the bottom", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_tetromino = board_before.active_tetromino
      
      Server.hard_drop(server)
      Process.sleep(10)  # Give it time to process
      
      {board_after, _} = Server.get_state(server)
      
      # The active tetromino should have changed
      refute board_after.active_tetromino == original_tetromino
      
      # Landed tetrominos should have blocks now
      assert MapSet.size(board_after.landed_tetrominos) > 0
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
    
    test "movement commands do nothing when game is paused", %{server: server} do
      # First pause the game
      Server.toggle_pause(server)
      Process.sleep(10)
      
      {board_before, paused} = Server.get_state(server)
      assert paused == true
      
      # Try all movement commands
      Server.move_left(server)
      Server.move_right(server)
      Server.rotate(server)
      Server.drop(server)
      Process.sleep(10)
      
      {board_after, _} = Server.get_state(server)
      
      # Board should remain unchanged
      assert board_before.active_tetromino.location == board_after.active_tetromino.location
      assert board_before.active_tetromino.rotation == board_after.active_tetromino.rotation
    end
  end

  describe "set_difficulty/2" do
    test "updates the difficulty of the game board", %{server: server} do
      {board_before, _} = Server.get_state(server)
      assert board_before.difficulty == :normal
      
      Server.set_difficulty(server, :expert)
      Process.sleep(10)
      
      {board_after, _} = Server.get_state(server)
      assert board_after.difficulty == :expert
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
  end
  describe "load_game/2" do
    test "loads a saved game state", %{server: server} do
      # Create a custom board state to load
      saved_board = %{
        width: 10,
        height: 20,
        score: 1000,
        level: 3,
        lines_cleared: 25,
        difficulty: :hard,
        game_over: false,
        active_tetromino: nil,
        next_tetromino: nil,
        landed_tetrominos: MapSet.new()
      }
        Server.load_game(server, saved_board)
      Process.sleep(10)
      
      {current_board, paused} = Server.get_state(server)
      
      # Board should match the saved state
      assert current_board.score == 1000
      assert current_board.level == 3
      assert current_board.lines_cleared == 25
      assert current_board.difficulty == :hard
      
      # Game should be paused after loading
      assert paused == true
      
      # Verify broadcast was sent
      assert_receive {:pubsub_broadcast, {:tetris_update, _}}
    end
  end

  describe "automatic ticks" do
    test "game ticks automatically drop the piece", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_position = board_before.active_tetromino.location
      
      # Wait for automatic tick (might need to adjust timing)
      Process.sleep(1100)
      
      {board_after, _} = Server.get_state(server)
      new_position = board_after.active_tetromino.location
      
      # Position should move down (y increases)
      assert elem(new_position, 0) == elem(original_position, 0)
      assert elem(new_position, 1) > elem(original_position, 1)
    end
    
    test "game ticks stop when game is paused", %{server: server} do
      {board_before, _} = Server.get_state(server)
      original_position = board_before.active_tetromino.location
      
      # Pause the game
      Server.toggle_pause(server)
      Process.sleep(10)
      
      # Wait for what would be an automatic tick
      Process.sleep(1100)
      
      {board_after, _} = Server.get_state(server)
      new_position = board_after.active_tetromino.location
      
      # Position should remain the same
      assert new_position == original_position
    end
      test "game ticks stop when game is over", %{server: server} do
      # Create a board where the game is over
      game_over_board = Map.put(Board.new(), :game_over, true)
      Server.load_game(server, game_over_board)
      Process.sleep(10)
      
      {board_before, _} = Server.get_state(server)
      
      # Wait for what would be an automatic tick
      Process.sleep(1100)
      
      {board_after, _} = Server.get_state(server)
      
      # Board should remain unchanged
      assert board_before == board_after
    end
  end
end
