defmodule TronTetris.Game.ScoreService do
  @moduledoc """
  Service module for managing high scores and saved games.
  """

  import Ecto.Query
  alias TronTetris.Repo
  alias TronTetris.Game.{HighScore, SavedGame}
  alias TronTetris.Accounts.Player

  @doc """
  Saves a high score.
  """
  def save_high_score(
        %Player{id: player_id},
        %{score: score, level: level, lines_cleared: lines} = attrs
      ) do
    play_time = Map.get(attrs, :play_time_seconds, 0)

    %HighScore{}
    |> HighScore.changeset(%{
      player_id: player_id,
      score: score,
      level: level,
      lines_cleared: lines,
      play_time_seconds: play_time
    })
    |> Repo.insert()
  end

  @doc """
  Gets top high scores.
  """
  def get_top_scores(limit \\ 10) do
    HighScore.top_scores_query(limit)
    |> Repo.all()
  end

  @doc """
  Gets high scores for a player.
  """
  def get_player_high_scores(player_id) do
    from(hs in HighScore,
      where: hs.player_id == ^player_id,
      order_by: [desc: hs.score],
      limit: 10
    )
    |> Repo.all()
  end

  @doc """
  Saves a game state.
  """
  def save_game(%Player{id: player_id}, board) do
    # Serialize the game board
    serialized_board = :erlang.term_to_binary(board)

    %SavedGame{}
    |> SavedGame.changeset(%{
      player_id: player_id,
      game_state: serialized_board,
      score: board.score,
      level: board.level,
      lines_cleared: board.lines_cleared
    })
    |> Repo.insert()
  end

  @doc """
  Gets the most recent saved game for a player.
  """
  def get_last_saved_game(player_id) do
    saved_game =
      from(sg in SavedGame,
        where: sg.player_id == ^player_id,
        order_by: [desc: sg.inserted_at],
        limit: 1
      )
      |> Repo.one()

    case saved_game do
      nil -> {:error, :not_found}
      game -> {:ok, deserialize_game(game)}
    end
  end

  defp deserialize_game(%SavedGame{game_state: binary}) do
    :erlang.binary_to_term(binary)
  end
end
