defmodule TronTetrisWeb.Components.GameSettings do
  @moduledoc """
  LiveComponent for game settings including difficulty selection.
  """
  use TronTetrisWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="game-settings">
      <div class="settings-header">
        <div class="settings-title">SETTINGS</div>
        
        <button
          type="button"
          class="tron-button small"
          phx-click="close_settings"
          phx-target={@myself}
        >
          CLOSE
        </button>
      </div>
      
      <div class="settings-body">
        <div class="setting-group">
          <div class="setting-label">DIFFICULTY:</div>
          
          <div class="difficulty-buttons">
            <button
              type="button"
              class={"tron-button small #{if @difficulty == :easy, do: "active"}"}
              phx-click="set_difficulty"
              phx-value-difficulty="easy"
              phx-target={@myself}
            >
              EASY
            </button>
            <button
              type="button"
              class={"tron-button small #{if @difficulty == :normal, do: "active"}"}
              phx-click="set_difficulty"
              phx-value-difficulty="normal"
              phx-target={@myself}
            >
              NORMAL
            </button>
            <button
              type="button"
              class={"tron-button small #{if @difficulty == :hard, do: "active"}"}
              phx-click="set_difficulty"
              phx-value-difficulty="hard"
              phx-target={@myself}
            >
              HARD
            </button>
            <button
              type="button"
              class={"tron-button small #{if @difficulty == :expert, do: "active"}"}
              phx-click="set_difficulty"
              phx-value-difficulty="expert"
              phx-target={@myself}
            >
              EXPERT
            </button>
          </div>
        </div>
        
        <div class="setting-group">
          <div class="setting-label">SOUND:</div>
          
          <div class="sound-toggle">
            <button
              type="button"
              class={"tron-button small #{if @sound, do: "active"}"}
              phx-click="toggle_sound"
              phx-target={@myself}
            >
              {if @sound, do: "ON", else: "OFF"}
            </button>
          </div>
        </div>
        
        <div class="setting-info">
          <div class="setting-description">
            <strong>EASY</strong>: Slower speed, more forgiving scoring.
          </div>
          
          <div class="setting-description">
            <strong>NORMAL</strong>: Classic Tetris balance.
          </div>
          
          <div class="setting-description">
            <strong>HARD</strong>: Faster speed, higher scoring potential.
          </div>
          
          <div class="setting-description">
            <strong>EXPERT</strong>: Maximum speed, maximum challenge!
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("close_settings", _params, socket) do
    send(self(), {:menu_action, :close_settings})
    {:noreply, socket}
  end

  def handle_event("set_difficulty", %{"difficulty" => difficulty}, socket) do
    difficulty_atom = String.to_existing_atom(difficulty)
    send(self(), {:menu_action, {:set_difficulty, difficulty_atom}})
    {:noreply, assign(socket, :difficulty, difficulty_atom)}
  end

  def handle_event("toggle_sound", _params, socket) do
    new_sound_state = !socket.assigns.sound
    send(self(), {:menu_action, {:toggle_sound, new_sound_state}})
    {:noreply, assign(socket, :sound, new_sound_state)}
  end
end
