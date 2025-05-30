defmodule TronTetrisWeb.TetrisLive do
  @moduledoc """
  LiveView for the Tetris game.
  """
  use TronTetrisWeb, :live_view
  alias TronTetris.Game.{Server, Supervisor, Tetromino}
  alias Phoenix.PubSub

  # Mount the sound hooks
  on_mount TronTetrisWeb.Live.Hooks.SoundHooks

  # Helper functions for the HTML template

  def cell_classes(x, y, board) do
    active_points = Tetromino.to_absolute_coordinates(board.active_tetromino)

    cond do
      # Active tetromino cell
      {x, y} in active_points ->
        "cell #{Tetromino.color(board.active_tetromino.shape)} active"

      # Landed tetromino cell
      MapSet.member?(board.landed_tetrominos, {x, y}) ->
        shape = find_shape_for_landed_cell({x, y}, board)
        "cell #{shape} landed"

      # Empty cell
      true ->
        "cell empty"
    end
  end

  def find_shape_for_landed_cell({_x, _y}, _board) do
    # For simplicity, we're not tracking the shape of landed cells,
    # so we'll make them all the same "tron" color.
    "tron"
  end

  def render_next_tetromino(tetromino) do
    points = Tetromino.points(tetromino.shape)
    color = Tetromino.color(tetromino.shape)

    # Find the dimensions of the next tetromino preview area
    {min_x, max_x} = points |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = points |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    # Create a grid that's large enough for any tetromino
    width_val = max(4, max_x - min_x + 3)
    height_val = max(4, max_y - min_y + 3)

    # Offset to center the tetromino
    offset_x_val = div(width_val - (max_x - min_x + 1), 2)
    offset_y_val = div(height_val - (max_y - min_y + 1), 2)

    # Generate the HTML grid
    assigns = %{
      points: points,
      color: color,
      width_val: width_val,
      height_val: height_val,
      offset_x_val: offset_x_val,
      offset_y_val: offset_y_val
    }

    ~H"""
    <div class="next-piece-grid">
      <%= for y <- 0..(@height_val-1) do %>
        <div class="next-row">
          <%= for x <- 0..(@width_val-1) do %>
            <div class={next_cell_class({x - @offset_x_val, y - @offset_y_val}, @points, @color)}>
              <div class="cell-inner"></div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp next_cell_class(point, points, color) do
    if point in points do
      "cell #{color} active"
    else
      "cell empty"
    end
  end

  @impl true
  # Check if player ID is in params or generate a new one
  def mount(params, _session, socket) do
    player_id = Map.get(params, "player_id", generate_player_id())

    # Try to get player from the database if logged in
    # First check if this is a numeric ID that could reference a player record
    player =
      case Integer.parse(to_string(player_id)) do
        {_int_id, ""} ->
          # Looks like a valid integer, try to find the player
          TronTetris.Accounts.get_player(player_id)

        _ ->
          # Not a valid integer ID, just use it as a session identifier
          nil
      end

    # Start a game server for this player
    {:ok, _pid} = Supervisor.start_game(player_id)

    # Subscribe to game updates
    if connected?(socket) do
      PubSub.subscribe(TronTetris.PubSub, "tetris:#{player_id}")
    end

    # Get initial game state
    {board, paused} = Server.get_state(Supervisor.server_name(player_id))

    {:ok,
     socket
     |> assign(:player_id, player_id)
     |> assign(:player, player)
     |> assign(:board, board)
     |> assign(:paused, paused)
     |> assign(:show_login_prompt, false)
     |> assign(:save_success, false)
     |> assign(:show_settings, false)
     |> assign(:difficulty, board.difficulty || :normal)
     |> assign(:sound, true)}
  end

  @impl true
  def handle_event("keydown", %{"key" => key}, socket) do
    server = Supervisor.server_name(socket.assigns.player_id)

    case key do
      "ArrowLeft" ->
        Server.move_left(server)
        send(self(), {:action, :move})

      "ArrowRight" ->
        Server.move_right(server)
        send(self(), {:action, :move})

      "ArrowUp" ->
        Server.rotate(server)
        send(self(), {:action, :rotate})

      "ArrowDown" ->
        Server.drop(server)
        send(self(), {:action, :drop})

      " " ->
        Server.toggle_pause(server)

      "p" ->
        Server.toggle_pause(server)

      "r" ->
        Server.new_game(server)

      _ ->
        :ignore
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("new_game", _params, socket) do
    server = Supervisor.server_name(socket.assigns.player_id)
    board = Server.new_game(server)

    {:noreply, assign(socket, :board, board)}
  end

  @impl true
  def handle_event("toggle_pause", _params, socket) do
    server = Supervisor.server_name(socket.assigns.player_id)
    Server.toggle_pause(server)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:tetris_update, board}, socket) do
    # Get the current paused state from the server instead of using the old socket state
    server = Supervisor.server_name(socket.assigns.player_id)
    {_current_board, paused} = Server.get_state(server)

    {:noreply, socket |> assign(:board, board) |> assign(:paused, paused)}
  end

  @impl true
  def handle_info(:hide_save_success, socket) do
    {:noreply, assign(socket, :save_success, false)}
  end

  @impl true
  def handle_info({:action, _action_type}, socket) do
    # Pass action events through - they will be handled by SoundHooks
    {:noreply, socket}
  end

  @impl true
  def handle_info({:menu_action, action}, socket) do
    case action do
      :new_game ->
        server = Supervisor.server_name(socket.assigns.player_id)
        board = Server.new_game(server, socket.assigns.difficulty)
        {:noreply, assign(socket, :board, board)}

      :toggle_pause ->
        server = Supervisor.server_name(socket.assigns.player_id)
        Server.toggle_pause(server)
        {:noreply, socket}

      :save_game ->
        handle_save_game(socket)

      :load_game ->
        handle_load_game(socket)

      :show_settings ->
        {:noreply, assign(socket, :show_settings, true)}

      :close_settings ->
        {:noreply, assign(socket, :show_settings, false)}

      {:set_difficulty, difficulty} ->
        server = Supervisor.server_name(socket.assigns.player_id)
        Server.set_difficulty(server, difficulty)
        {:noreply, assign(socket, :difficulty, difficulty)}

      {:toggle_sound, sound_state} ->
        # Update JS sound settings via a push_event
        {:noreply,
         socket
         |> assign(:sound, sound_state)
         |> push_event("toggle_sound", %{enabled: sound_state})}

      :logout ->
        {:noreply, redirect(socket, to: ~p"/login")}
    end
  end

  # Game save/load functions

  defp handle_save_game(%{assigns: %{player: nil}} = socket) do
    {:noreply, socket |> put_flash(:error, "You must be logged in to save a game")}
  end

  defp handle_save_game(%{assigns: %{player: player, board: board}} = socket) do
    case TronTetris.Game.ScoreService.save_game(player, board) do
      {:ok, _saved_game} ->
        # Show success message that will auto-hide
        Process.send_after(self(), :hide_save_success, 3000)
        {:noreply, assign(socket, :save_success, true)}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to save game")}
    end
  end

  defp handle_load_game(%{assigns: %{player: nil}} = socket) do
    {:noreply, socket |> put_flash(:error, "You must be logged in to load a game")}
  end

  defp handle_load_game(%{assigns: %{player: player, player_id: player_id}} = socket) do
    case TronTetris.Game.ScoreService.get_last_saved_game(player.id) do
      {:ok, board} ->
        server = Supervisor.server_name(player_id)
        # Load the saved game state into the server
        loaded_board = Server.load_game(server, board)

        {:noreply,
         socket
         |> assign(:board, loaded_board)
         |> assign(:paused, true)
         |> put_flash(:info, "Game loaded successfully")}

      {:error, :not_found} ->
        {:noreply, socket |> put_flash(:error, "No saved games found")}
    end
  end

  # Helper functions
  defp generate_player_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end
end
