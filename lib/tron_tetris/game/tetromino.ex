defmodule TronTetris.Game.Tetromino do
  @moduledoc """
  Defines the tetromino shapes and their transformations.
  Each tetromino is represented as a list of {x, y} coordinates.
  """

  @type point :: {integer, integer}
  @type points :: list(point)
  @type tetromino :: %{shape: atom, points: points, location: point, rotation: integer}

  @doc """
  Creates a new tetromino of the specified shape.
  """
  def new(shape \\ random_shape()) do
    %{
      shape: shape,
      points: points(shape),
      location: {4, 0},
      rotation: 0
    }
  end

  @doc """
  Returns a random shape.
  """
  def random_shape do
    ~w(i j l o s t z)a |> Enum.random()
  end

  @doc """
  Returns the points for a tetromino shape.
  """
  def points(:i), do: [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
  def points(:j), do: [{0, 0}, {0, 1}, {1, 1}, {2, 1}]
  def points(:l), do: [{0, 1}, {1, 1}, {2, 1}, {2, 0}]
  def points(:o), do: [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
  def points(:s), do: [{0, 1}, {1, 1}, {1, 0}, {2, 0}]
  def points(:t), do: [{0, 1}, {1, 1}, {2, 1}, {1, 0}]
  def points(:z), do: [{0, 0}, {1, 0}, {1, 1}, {2, 1}]

  @doc """
  Translates a tetromino by dx, dy.
  """
  def translate(%{location: {x, y}} = tetromino, {dx, dy}) do
    %{tetromino | location: {x + dx, y + dy}}
  end

  @doc """
  Rotates a tetromino clockwise.
  """
  def rotate(%{rotation: rotation} = tetromino) do
    %{tetromino | rotation: rem(rotation + 1, 4)}
  end

  @doc """
  Returns the absolute coordinates of a tetromino.
  """
  def to_absolute_coordinates(%{
        points: points,
        location: {offset_x, offset_y},
        rotation: rotation
      }) do
    points
    |> rotate_points(rotation)
    |> Enum.map(fn {x, y} -> {x + offset_x, y + offset_y} end)
  end

  @doc """
  Rotates a list of points by the given rotation index.
  """
  def rotate_points(points, 0), do: points
  def rotate_points(points, 1), do: points |> Enum.map(fn {x, y} -> {-y, x} end)
  def rotate_points(points, 2), do: points |> Enum.map(fn {x, y} -> {-x, -y} end)
  def rotate_points(points, 3), do: points |> Enum.map(fn {x, y} -> {y, -x} end)

  @doc """
  Returns the color for a tetromino shape.
  """
  def color(:i), do: "cyan"
  def color(:j), do: "blue"
  def color(:l), do: "orange"
  def color(:o), do: "yellow"
  def color(:s), do: "green"
  def color(:t), do: "purple"
  def color(:z), do: "red"
end
