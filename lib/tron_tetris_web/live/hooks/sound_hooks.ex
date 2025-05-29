defmodule TronTetrisWeb.Live.Hooks.SoundHooks do
  @moduledoc """
  Hooks for playing sounds in the Tetris game.
  These hooks will inject JavaScript to play sounds on game events.
  """
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:tetris_sounds, :handle_info, &handle_sounds/2)}
  end

  # Handles various game events and injects JS commands to play corresponding sounds
  defp handle_sounds({:tetris_update, %{game_over: true}}, socket) do
    # Game over sound
    {:halt, push_event(socket, "play_sound", %{name: "game_over"})}
  end

  defp handle_sounds({:tetris_update, new_board}, socket) do
    old_board = socket.assigns[:board]

    cond do
      # Check if lines were cleared
      old_board && new_board.lines_cleared > old_board.lines_cleared ->
        sound = if new_board.lines_cleared - old_board.lines_cleared >= 4, do: "tetris", else: "line_clear"
        {:halt, push_event(socket, "play_sound", %{name: sound})}

      # Check if level increased
      old_board && new_board.level > old_board.level ->
        {:halt, push_event(socket, "play_sound", %{name: "level_up"})}

      # No special event, let the event continue normally
      true ->
        {:cont, socket}
    end
  end

  # Handle rotation
  defp handle_sounds({:action, :rotate}, socket) do
    {:halt, push_event(socket, "play_sound", %{name: "rotate"})}
  end

  # Handle movement
  defp handle_sounds({:action, :move}, socket) do
    {:halt, push_event(socket, "play_sound", %{name: "move"})}
  end

  # Handle drop
  defp handle_sounds({:action, :drop}, socket) do
    {:halt, push_event(socket, "play_sound", %{name: "drop"})}
  end

  # Let other events pass through
  defp handle_sounds(_event, socket), do: {:cont, socket}
end
