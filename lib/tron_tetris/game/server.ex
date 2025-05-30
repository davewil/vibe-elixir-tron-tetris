defmodule TronTetris.Game.Server do
  @moduledoc """
  GenServer implementation for the Tetris game.
  Manages the game state and timing.
  """

  use GenServer
  alias TronTetris.Game.Board
  alias Phoenix.PubSub

  # Default interval in milliseconds
  @tick_interval 1000

  # Client API
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def new_game(server \\ __MODULE__, difficulty \\ :normal) do
    GenServer.call(server, {:new_game, difficulty})
  end

  def get_state(server \\ __MODULE__) do
    GenServer.call(server, :get_state)
  end

  def load_game(server \\ __MODULE__, board) do
    GenServer.call(server, {:load_game, board})
  end

  def set_difficulty(server \\ __MODULE__, difficulty) do
    GenServer.call(server, {:set_difficulty, difficulty})
  end

  def move_left(server \\ __MODULE__) do
    GenServer.cast(server, :move_left)
  end

  def move_right(server \\ __MODULE__) do
    GenServer.cast(server, :move_right)
  end

  def rotate(server \\ __MODULE__) do
    GenServer.cast(server, :rotate)
  end

  def hard_drop(server \\ __MODULE__) do
    GenServer.cast(server, :hard_drop)
  end

  def toggle_pause(server \\ __MODULE__) do
    GenServer.cast(server, :toggle_pause)
  end

  def drop(server \\ __MODULE__) do
    GenServer.cast(server, :drop)
  end

  # Callbacks

  @impl true
  def init(opts) do
    player_id = Keyword.get(opts, :player_id, "default")
    board = Board.new()

    {:ok, %{board: board, player_id: player_id, paused: false}, {:continue, :schedule_tick}}
  end

  @impl true
  def handle_continue(:schedule_tick, state) do
    schedule_tick(state.board.level)
    {:noreply, state}
  end

  @impl true
  def handle_call({:new_game, difficulty}, _from, state) do
    board = Board.new(difficulty)
    broadcast_update(board, state.player_id)
    {:reply, board, %{state | board: board, paused: false}, {:continue, :schedule_tick}}
  end

  @impl true
  def handle_call(:new_game, from, state) do
    handle_call({:new_game, :normal}, from, state)
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {state.board, state.paused}, state}
  end

  @impl true
  def handle_call({:load_game, board}, _from, state) do
    broadcast_update(board, state.player_id)
    {:reply, board, %{state | board: board, paused: true}, {:continue, :schedule_tick}}
  end

  @impl true
  def handle_call({:set_difficulty, difficulty}, _from, state) do
    new_board = %{state.board | difficulty: difficulty}
    broadcast_update(new_board, state.player_id)
    {:reply, new_board, %{state | board: new_board}}
  end

  @impl true
  def handle_cast(:move_left, %{paused: true} = state), do: {:noreply, state}
  @impl true
  def handle_cast(:move_left, state) do
    new_board = Board.move_left(state.board)
    broadcast_update(new_board, state.player_id)
    {:noreply, %{state | board: new_board}}
  end

  @impl true
  def handle_cast(:move_right, %{paused: true} = state), do: {:noreply, state}
  @impl true
  def handle_cast(:move_right, state) do
    new_board = Board.move_right(state.board)
    broadcast_update(new_board, state.player_id)
    {:noreply, %{state | board: new_board}}
  end

  @impl true
  def handle_cast(:rotate, %{paused: true} = state), do: {:noreply, state}
  @impl true
  def handle_cast(:rotate, state) do
    new_board = Board.rotate(state.board)
    broadcast_update(new_board, state.player_id)
    {:noreply, %{state | board: new_board}}
  end

  @impl true
  def handle_cast(:hard_drop, %{paused: true} = state), do: {:noreply, state}
  @impl true
  def handle_cast(:hard_drop, state) do
    new_board = Board.hard_drop(state.board)
    broadcast_update(new_board, state.player_id)
    {:noreply, %{state | board: new_board}}
  end

  @impl true
  def handle_cast(:toggle_pause, %{paused: paused} = state) do
    # When unpausing, schedule a tick
    if paused, do: schedule_tick(state.board.level)

    {:noreply, %{state | paused: not paused}}
  end

  @impl true
  def handle_cast(:drop, %{paused: true} = state), do: {:noreply, state}
  @impl true
  def handle_cast(:drop, state) do
    new_board = Board.drop(state.board)
    broadcast_update(new_board, state.player_id)

    # Only schedule the next tick if the game isn't over
    if not new_board.game_over do
      schedule_tick(new_board.level)
    end

    {:noreply, %{state | board: new_board}}
  end

  @impl true
  def handle_info(:tick, %{paused: true} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{board: %{game_over: true}} = state) do
    # Don't schedule more ticks if the game is over
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    new_board = Board.drop(state.board)
    broadcast_update(new_board, state.player_id)

    # Only schedule the next tick if the game isn't over
    if not new_board.game_over do
      schedule_tick(new_board.level)
    end

    {:noreply, %{state | board: new_board}}
  end

  # Private functions
  defp schedule_tick(level) when is_integer(level) do
    # Adjust speed based on level
    interval = max(100, @tick_interval - (level - 1) * 50)
    Process.send_after(self(), :tick, interval)
  end

  defp schedule_tick(%{level: level, difficulty: difficulty}) do
    # Adjust base speed on difficulty
    base_interval =
      case difficulty do
        :easy -> @tick_interval + 200
        :normal -> @tick_interval
        :hard -> @tick_interval - 100
        :expert -> @tick_interval - 200
        _ -> @tick_interval
      end

    # Apply level-based speed adjustment
    interval = max(100, base_interval - (level - 1) * 50)
    Process.send_after(self(), :tick, interval)
  end

  defp broadcast_update(board, player_id) do
    PubSub.broadcast(TronTetris.PubSub, "tetris:#{player_id}", {:tetris_update, board})
  end
end
