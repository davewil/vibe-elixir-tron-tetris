defmodule TronTetrisWeb.ProfileLive do
  @moduledoc """
  LiveView for player profiles.
  """

  use TronTetrisWeb, :live_view
  alias TronTetris.Accounts
  alias TronTetris.Game.ScoreService

  @impl true
  def mount(%{"id" => player_id}, _session, socket) do
    case Accounts.get_player(player_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Player not found")
         |> redirect(to: ~p"/")}

      player ->
        high_scores = ScoreService.get_player_high_scores(player_id)

        {:ok,
         socket
         |> assign(:page_title, "#{player.username}'s Profile")
         |> assign(:player, player)
         |> assign(:high_scores, high_scores)}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> put_flash(:error, "Player ID required")
     |> redirect(to: ~p"/")}
  end

  @impl true
  def handle_event("back_to_game", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/tetris")}
  end

  # Helper function to format time
  def format_time(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)
    "#{minutes}:#{String.pad_leading("#{remaining_seconds}", 2, "0")}"
  end

  # Helper function to format date
  def format_date(datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M")
  end
end
