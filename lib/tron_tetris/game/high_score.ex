defmodule TronTetris.Game.HighScore do
  @moduledoc """
  Schema for high scores.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  
  schema "high_scores" do
    field :score, :integer
    field :level, :integer
    field :lines_cleared, :integer
    field :play_time_seconds, :integer
    
    belongs_to :player, TronTetris.Accounts.Player
    
    timestamps()
  end
  
  @doc """
  Changeset for creating or updating a high score.
  """
  def changeset(high_score, attrs) do
    high_score
    |> cast(attrs, [:player_id, :score, :level, :lines_cleared, :play_time_seconds])
    |> validate_required([:player_id, :score, :level, :lines_cleared, :play_time_seconds])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> validate_number(:level, greater_than_or_equal_to: 1)
    |> validate_number(:lines_cleared, greater_than_or_equal_to: 0)
    |> validate_number(:play_time_seconds, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:player_id)
  end
  
  @doc """
  Query to get top high scores.
  """
  def top_scores_query(limit \\ 10) do
    from hs in __MODULE__,
      join: p in assoc(hs, :player),
      order_by: [desc: hs.score],
      limit: ^limit,
      select: %{
        id: hs.id,
        username: p.username,
        score: hs.score,
        level: hs.level,
        lines_cleared: hs.lines_cleared,
        play_time: hs.play_time_seconds,
        inserted_at: hs.inserted_at
      }
  end
end
