defmodule TronTetrisWeb.LeaderboardLive do
  @moduledoc """
  LiveView for displaying the leaderboard.
  """

  use TronTetrisWeb, :live_view
  alias TronTetris.Game.ScoreService

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Refresh the leaderboard every 30 seconds
      :timer.send_interval(30_000, self(), :refresh_leaderboard)
    end

    top_scores = ScoreService.get_top_scores(20)

    {:ok,
     assign(socket,
       page_title: "Leaderboard",
       top_scores: top_scores
     )}
  end

  @impl true
  def handle_info(:refresh_leaderboard, socket) do
    top_scores = ScoreService.get_top_scores(20)
    {:noreply, assign(socket, :top_scores, top_scores)}
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
end
