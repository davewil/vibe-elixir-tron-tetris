defmodule TronTetris.Repo.Migrations.CreateGameTables do
  use Ecto.Migration

  def change do
    # Create players table
    create table(:players) do
      add :username, :string, null: false
      add :email, :string
      add :hashed_password, :string
      
      timestamps()
    end

    create unique_index(:players, [:username])
    create unique_index(:players, [:email])

    # Create high scores table
    create table(:high_scores) do
      add :player_id, references(:players, on_delete: :delete_all), null: false
      add :score, :integer, null: false
      add :level, :integer, null: false
      add :lines_cleared, :integer, null: false
      add :play_time_seconds, :integer, null: false
      
      timestamps()
    end

    create index(:high_scores, [:player_id])
    create index(:high_scores, [:score])

    # Create saved games table
    create table(:saved_games) do
      add :player_id, references(:players, on_delete: :delete_all), null: false
      add :game_state, :binary, null: false  # Stored as serialized binary
      add :score, :integer, null: false
      add :level, :integer, null: false
      add :lines_cleared, :integer, null: false
      
      timestamps()
    end

    create index(:saved_games, [:player_id])
  end
end
