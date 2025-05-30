defmodule TronTetris.Game.Board do
  @moduledoc """
  Represents the game board, handling the collision detection
  and piece placement.
  """

  alias TronTetris.Game.Tetromino

  @type t :: %{
          width: integer,
          height: integer,
          active_tetromino: Tetromino.tetromino(),
          next_tetromino: Tetromino.tetromino(),
          landed_tetrominos: MapSet.t(Tetromino.point()),
          score: integer,
          level: integer,
          lines_cleared: integer,
          game_over: boolean,
          difficulty: atom
        }

  @board_width 10
  @board_height 20

  @doc """
  Creates a new game board.
  """
  def new(difficulty \\ :normal) do
    %{
      width: @board_width,
      height: @board_height,
      active_tetromino: Tetromino.new(),
      next_tetromino: Tetromino.new(),
      landed_tetrominos: MapSet.new(),
      score: 0,
      level: 1,
      lines_cleared: 0,
      game_over: false,
      difficulty: difficulty
    }
  end

  @doc """
  Moves the active tetromino down by one step.
  If the tetromino can't move down, it lands and a new tetromino is spawned.
  """
  # Restore original drop/1 logic and row clear handling
  def drop(%{game_over: true} = board), do: board
  def drop(%{active_tetromino: nil} = board), do: board

  def drop(board) do
    new_tetromino = Tetromino.translate(board.active_tetromino, {0, 1})

    cond do
      is_nil(board.active_tetromino) ->
        %{board | game_over: true}

      valid_position?(new_tetromino, board) ->
        %{board | active_tetromino: new_tetromino}

      true ->
        landed = land_tetromino(board)

        if is_nil(landed.active_tetromino) do
          %{landed | game_over: true}
        else
          landed
        end
    end
  end

  # Remove unused clear_full_rows/1 helper
  # defp clear_full_rows(board) do
  #   {cleared_landed, lines_cleared} = clear_lines(board.landed_tetrominos, board.height, board.width)
  #   {%{board | landed_tetrominos: cleared_landed, lines_cleared: board.lines_cleared + lines_cleared}, lines_cleared}
  # end

  # Remove unused helpers (now replaced by main logic)
  # defp score_for_lines(0, _level), do: 0
  # defp score_for_lines(1, level), do: 40 * (level + 1)
  # defp score_for_lines(2, level), do: 100 * (level + 1)
  # defp score_for_lines(3, level), do: 300 * (level + 1)
  # defp score_for_lines(4, level), do: 1200 * (level + 1)
  # defp calculate_level(score), do: div(score, 1000)

  @doc """
  Moves the active tetromino left.
  """
  def move_left(%{game_over: true} = board), do: board

  def move_left(board) do
    new_tetromino = Tetromino.translate(board.active_tetromino, {-1, 0})

    if valid_position?(new_tetromino, board) do
      %{board | active_tetromino: new_tetromino}
    else
      board
    end
  end

  @doc """
  Moves the active tetromino right.
  """
  def move_right(%{game_over: true} = board), do: board

  def move_right(board) do
    new_tetromino = Tetromino.translate(board.active_tetromino, {1, 0})

    if valid_position?(new_tetromino, board) do
      %{board | active_tetromino: new_tetromino}
    else
      board
    end
  end

  @doc """
  Rotates the active tetromino.
  """
  def rotate(%{game_over: true} = board), do: board

  def rotate(%{active_tetromino: nil} = board), do: board

  def rotate(%{active_tetromino: active_tetromino} = board) do
    # Create a deep copy of the active tetromino to test rotation
    original_tetromino = %{
      shape: active_tetromino.shape,
      points: active_tetromino.points,
      location: active_tetromino.location,
      rotation: active_tetromino.rotation
    }
    
    # Create a copy with the next rotation value
    next_rotation = rem(original_tetromino.rotation + 1, 4)
    rotated_tetromino = %{original_tetromino | rotation: next_rotation}
    
    # Check if the rotated position would be valid on the board
    if valid_position?(rotated_tetromino, board) do
      # Update the board with the rotated tetromino
      %{board | active_tetromino: rotated_tetromino}
    else
      # Keep the original unrotated tetromino
      board
    end
  end

  @doc """
  Hard drops the active tetromino, landing it immediately.
  """
  def hard_drop(%{game_over: true} = board), do: board

  def hard_drop(%{active_tetromino: nil} = board), do: board

  def hard_drop(board) do
    # Find the lowest valid position for the tetromino
    final_y = find_landing_position(board.active_tetromino, board)
    
    if final_y == elem(board.active_tetromino.location, 1) do
      # Tetromino can't move down, just land it
      land_tetromino(board)
    else
      # Move the tetromino to the landing position and then land it
      landed_tetromino = %{
        board.active_tetromino | 
        location: {elem(board.active_tetromino.location, 0), final_y}
      }
      land_tetromino(%{board | active_tetromino: landed_tetromino})
    end
  end
  
  # Helper to find the lowest valid y-position for a tetromino
  defp find_landing_position(tetromino, board) do
    curr_y = elem(tetromino.location, 1)
    curr_x = elem(tetromino.location, 0)
    
    # Try each position down until we hit an invalid one
    Stream.iterate(curr_y, &(&1 + 1))
    |> Stream.take(board.height)
    |> Enum.reduce_while(curr_y, fn y, last_valid_y ->
      test_tetromino = %{tetromino | location: {curr_x, y}}
      if valid_position?(test_tetromino, board) do
        {:cont, y}  # Keep going down
      else
        {:halt, last_valid_y}  # Stop at the last valid position
      end
    end)
  end

  @doc """
  Determines if the tetromino is in a valid position.
  """
  def valid_position?(tetromino, board) do
    absolute_points = Tetromino.to_absolute_coordinates(tetromino)

    Enum.all?(absolute_points, fn {x, y} ->
      # Within horizontal bounds
      # Within vertical bounds
      # Not colliding with landed tetrominos
      x >= 0 and x < board.width and
        y >= 0 and y < board.height and
        not MapSet.member?(board.landed_tetrominos, {x, y})
    end)
  end

  @doc """
  Lands the active tetromino and spawns a new one.
  Also clears completed lines and checks for game over.
  """
  def land_tetromino(board) do
    # Add the active tetromino's points to the landed tetrominos
    new_landed =
      board.active_tetromino
      |> Tetromino.to_absolute_coordinates()
      |> Enum.reduce(board.landed_tetrominos, fn point, acc -> MapSet.put(acc, point) end)

    # Clear completed rows
    {cleared_landed, lines_cleared} = clear_lines(new_landed, board.height, board.width)

    # Calculate score increase
    score_increase = calculate_score(lines_cleared, board.level)
    # Update level if needed
    new_total_lines = board.lines_cleared + lines_cleared
    new_level = calculate_level(new_total_lines, board)

    # Prepare next tetromino - ensure it's different from the current next tetromino
    current_shape = board.next_tetromino.shape
    next_tetromino = 
      Stream.repeatedly(fn -> Tetromino.new() end)
      |> Enum.find(fn t -> t.shape != current_shape end)

    new_board = %{
      board
      | active_tetromino: board.next_tetromino,
        next_tetromino: next_tetromino,
        landed_tetrominos: cleared_landed,
        score: board.score + score_increase,
        lines_cleared: new_total_lines,
        level: new_level
    }

    # Check if the new active tetromino collides with the landed tetrominos
    # If so, try to spawn the next tetromino (fresh) before game over
    if valid_position?(new_board.active_tetromino, new_board) do
      new_board
    else
      # Try to spawn a fresh tetromino (in case the previous next_tetromino was blocked by a just-cleared line)
      try_fresh_board = %{
        new_board
        | active_tetromino: next_tetromino,
          next_tetromino: Tetromino.new()
      }

      if valid_position?(try_fresh_board.active_tetromino, try_fresh_board) do
        try_fresh_board
      else
        %{new_board | game_over: true}
      end
    end
  end

  @doc """
  Clears completed lines from the board.
  """
  def clear_lines(landed, _height, width) do
    # Group points by y coordinate
    points_by_row = Enum.group_by(landed, fn {_x, y} -> y end)

    # Find completed lines (rows with width number of blocks)
    completed_rows =
      points_by_row
      |> Enum.filter(fn {_y, points} -> length(points) == width end)
      |> Enum.map(fn {y, _} -> y end)
      |> Enum.sort()

    # If no lines were cleared, return the original landed set
    if Enum.empty?(completed_rows) do
      {landed, 0}
    else
      # Remove completed rows
      new_landed =
        MapSet.filter(landed, fn {_x, y} -> not Enum.member?(completed_rows, y) end)

      # Shift rows down
      shifted_landed =
        new_landed
        |> Enum.map(fn {x, y} ->
          # Calculate how many rows above this point were cleared
          shift = Enum.count(completed_rows, fn r -> r < y end)
          {x, y + shift}
        end)
        |> MapSet.new()

      {shifted_landed, length(completed_rows)}
    end
  end

  @doc """
  Calculates score based on lines cleared and level.
  """
  def calculate_score(0, _level), do: 0
  def calculate_score(1, level), do: 40 * level
  def calculate_score(2, level), do: 100 * level
  def calculate_score(3, level), do: 300 * level
  def calculate_score(4, level), do: 1200 * level
  def calculate_score(lines, level), do: 1200 * level + (lines - 4) * 100 * level

  @doc """
  Calculate level based on total lines cleared and difficulty.
  """
  def calculate_level(lines, %{difficulty: :easy}) do
    # Slower level progression
    max(1, div(lines, 15) + 1)
  end

  def calculate_level(lines, %{difficulty: :hard}) do
    # Faster level progression
    max(1, div(lines, 8) + 1)
  end

  def calculate_level(lines, %{difficulty: :expert}) do
    # Much faster level progression
    max(1, div(lines, 5) + 1)
  end

  def calculate_level(lines, _) do
    # Normal difficulty (default)
    max(1, div(lines, 10) + 1)
  end

  @doc """
  Resets the game board to a new game state.
  """
  def reset(_board), do: new()
end
