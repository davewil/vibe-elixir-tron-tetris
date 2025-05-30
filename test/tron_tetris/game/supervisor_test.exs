defmodule TronTetris.Game.SupervisorTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.{Supervisor, Server}

  # Test setup with separate supervision tree to avoid conflicts
  setup do
    # Create test registries and supervisor to avoid conflicts
    {:ok, _registry} = start_supervised({Registry, keys: :unique, name: TestGameRegistry})
    {:ok, supervisor} = start_supervised({DynamicSupervisor, name: TestGameSupervisor, strategy: :one_for_one})

    %{supervisor: supervisor, registry: TestGameRegistry}
  end
  test "start_game/1 starts a new game server", %{supervisor: supervisor, registry: registry} do
    player_id = "test_player_#{:erlang.unique_integer([:positive])}"
    
    # Create a child spec that uses our test infrastructure
    child_spec = %{
      id: Server,
      start: {Server, :start_link, [[name: {:via, Registry, {registry, player_id}}, player_id: player_id]]},
      restart: :temporary
    }
    
    # Start a game for the player
    {:ok, pid} = DynamicSupervisor.start_child(supervisor, child_spec)
    assert is_pid(pid)
    
    # Check if the process is registered
    [{^pid, _}] = Registry.lookup(registry, player_id)
    
    # Try starting the same game again, should return the existing pid or an already_started error
    result = DynamicSupervisor.start_child(supervisor, child_spec)
    case result do
      {:ok, _second_pid} -> assert false, "Should not be able to start duplicate servers"
      {:error, {:already_started, existing_pid}} -> assert existing_pid == pid
    end
  end
  test "stop_game/1 terminates a running game server", %{supervisor: supervisor, registry: registry} do
    player_id = "test_player_#{:erlang.unique_integer([:positive])}"
    
    # Create and start a game server
    child_spec = %{
      id: Server,
      start: {Server, :start_link, [[name: {:via, Registry, {registry, player_id}}, player_id: player_id]]},
      restart: :temporary
    }
    
    # Start a game
    {:ok, pid} = DynamicSupervisor.start_child(supervisor, child_spec)
    assert Process.alive?(pid)
    
    # Verify it's registered
    [{^pid, _}] = Registry.lookup(registry, player_id)
      # Stop the game
    :ok = DynamicSupervisor.terminate_child(supervisor, pid)
    
    # Process should be terminated
    refute Process.alive?(pid)
    
    # Give the registry time to clean up
    Process.sleep(10)
    
    # Registry should be empty
    [] = Registry.lookup(registry, player_id)
  end
end
