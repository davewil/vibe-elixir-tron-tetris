defmodule TronTetris.Game.Supervisor do
  @moduledoc """
  Supervisor for game servers. Creates a dynamic pool of game servers,
  one per player.
  """

  use DynamicSupervisor

  alias TronTetris.Game.Server

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new game server for a specific player.
  Returns the pid of the server.
  """
  def start_game(player_id) do
    child_spec = %{
      id: Server,
      start: {Server, :start_link, [[name: server_name(player_id), player_id: player_id]]},
      restart: :temporary
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  @doc """
  Returns the process name for a player's game server.
  """
  def server_name(player_id) do
    {:via, Registry, {TronTetris.GameRegistry, player_id}}
  end

  @doc """
  Stops a game for a specific player.
  """
  def stop_game(player_id) do
    case Registry.lookup(TronTetris.GameRegistry, player_id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      [] -> {:error, :not_found}
    end
  end
end
