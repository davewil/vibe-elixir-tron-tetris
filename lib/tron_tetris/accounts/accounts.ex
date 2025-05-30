defmodule TronTetris.Accounts do
  @moduledoc """
  Context module for player accounts.
  """

  alias TronTetris.Repo
  alias TronTetris.Accounts.Player

  @doc """
  Returns a list of players.
  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a player by ID.
  """
  def get_player(id) when is_integer(id), do: Repo.get(Player, id)

  def get_player(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} -> Repo.get(Player, int_id)
      # Not a valid integer ID
      _ -> nil
    end
  end

  def get_player(_), do: nil

  @doc """
  Gets a player by username.
  """
  def get_player_by_username(username) do
    Repo.get_by(Player, username: username)
  end

  @doc """
  Creates a new player.
  """
  def create_player(attrs) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.
  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Authenticates a player by username and password.
  """
  def authenticate_player(username, password) do
    player = get_player_by_username(username)

    with %{hashed_password: hashed_password} <- player,
         true <- verify_password(password, hashed_password) do
      {:ok, player}
    else
      _ -> {:error, :invalid_credentials}
    end
  end

  defp verify_password(password, hashed_password) do
    # In a real app, you'd use a proper password verification
    # For this demo, we'll use a simple hash check
    :crypto.hash(:sha256, password) |> Base.encode64() == hashed_password
  end
end
