defmodule TronTetrisWeb.Components.GameMenu do
  @moduledoc """
  Component for the game menu with navigation and user status.
  """

  use TronTetrisWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="game-menu">
      <div class="menu-header">
        <h2 class="menu-title">TRON TETRIS</h2>
        
        <div class="player-info">
          <%= if @player do %>
            <span class="username">USER: {@player.username}</span>
            <button class="tron-button small" phx-click="logout" phx-target={@myself}>LOGOUT</button>
          <% else %>
            <span class="guest-label">PLAYING AS GUEST</span>
            <a href="/login" class="tron-button small">LOGIN</a>
          <% end %>
        </div>
      </div>
      
      <div class="menu-actions">
        <button class="tron-button" phx-click="new_game" phx-target={@myself}>NEW GAME</button>
        <button class="tron-button" phx-click="toggle_pause" phx-target={@myself}>
          {if @paused, do: "RESUME", else: "PAUSE"}
        </button>
         <button class="tron-button" phx-click="show_settings" phx-target={@myself}>SETTINGS</button>
        <a href="/leaderboard" class="tron-button">LEADERBOARD</a>
        <%= if @player do %>
          <button class="tron-button" phx-click="save_game" phx-target={@myself}>SAVE GAME</button>
          <button class="tron-button" phx-click="load_game" phx-target={@myself}>LOAD GAME</button>
        <% end %>
      </div>
      
      <%= if @save_success do %>
        <div class="save-notification">Game saved successfully!</div>
      <% end %>
    </div>
    """
  end

  def handle_event("new_game", _params, socket) do
    send(self(), {:menu_action, :new_game})
    {:noreply, socket}
  end

  def handle_event("toggle_pause", _params, socket) do
    send(self(), {:menu_action, :toggle_pause})
    {:noreply, socket}
  end

  def handle_event("save_game", _params, socket) do
    send(self(), {:menu_action, :save_game})
    {:noreply, socket}
  end

  def handle_event("load_game", _params, socket) do
    send(self(), {:menu_action, :load_game})
    {:noreply, socket}
  end

  def handle_event("logout", _params, socket) do
    send(self(), {:menu_action, :logout})
    {:noreply, socket}
  end

  def handle_event("show_settings", _params, socket) do
    send(self(), {:menu_action, :show_settings})
    {:noreply, socket}
  end
end
