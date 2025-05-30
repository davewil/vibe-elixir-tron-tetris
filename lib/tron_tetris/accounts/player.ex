defmodule TronTetris.Accounts.Player do
  @moduledoc """
  Schema for player accounts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :high_scores, TronTetris.Game.HighScore
    has_many :saved_games, TronTetris.Game.SavedGame

    timestamps()
  end

  @doc """
  Changeset for creating a new player.
  """
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:password, min: 8, message: "must be at least 8 characters")
    |> validate_confirmation(:password, message: "passwords do not match")
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    # In a real app, you'd use a proper password hashing library like Argon2 or Bcrypt
    # For this demo, we'll use a simple hash
    hashed_password = :crypto.hash(:sha256, password) |> Base.encode64()
    put_change(changeset, :hashed_password, hashed_password)
  end

  defp hash_password(changeset), do: changeset
end
