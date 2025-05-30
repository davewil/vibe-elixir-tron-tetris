defmodule TronTetris.Game.SavedGame do
  @moduledoc """
  Schema for saved games.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "saved_games" do
    field :game_state, :binary
    field :score, :integer
    field :level, :integer
    field :lines_cleared, :integer

    belongs_to :player, TronTetris.Accounts.Player

    timestamps()
  end

  @doc """
  Changeset for creating or updating a saved game.
  """
  def changeset(saved_game, attrs) do
    saved_game
    |> cast(attrs, [:player_id, :game_state, :score, :level, :lines_cleared])
    |> validate_required([:player_id, :game_state, :score, :level, :lines_cleared])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> validate_number(:level, greater_than_or_equal_to: 1)
    |> validate_number(:lines_cleared, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:player_id)
  end
end
