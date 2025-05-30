defmodule TronTetris.Game.TetrominoTest do
  use ExUnit.Case, async: true
  alias TronTetris.Game.Tetromino

  describe "new/1" do
    test "creates a tetromino with the specified shape" do
      tetromino = Tetromino.new(:i)
      assert tetromino.shape == :i
      assert tetromino.points == Tetromino.points(:i)
      assert tetromino.location == {4, 0}
      assert tetromino.rotation == 0
    end

    test "creates a random tetromino when no shape is specified" do
      tetromino = Tetromino.new()
      assert tetromino.shape in [:i, :j, :l, :o, :s, :t, :z]
      assert tetromino.points == Tetromino.points(tetromino.shape)
      assert tetromino.location == {4, 0}
      assert tetromino.rotation == 0
    end
  end

  describe "random_shape/0" do
    test "returns one of the valid shapes" do
      assert Tetromino.random_shape() in [:i, :j, :l, :o, :s, :t, :z]
    end
  end

  describe "points/1" do
    test "returns the correct points for I tetromino" do
      assert Tetromino.points(:i) == [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
    end

    test "returns the correct points for J tetromino" do
      assert Tetromino.points(:j) == [{0, 0}, {0, 1}, {1, 1}, {2, 1}]
    end

    test "returns the correct points for L tetromino" do
      assert Tetromino.points(:l) == [{0, 1}, {1, 1}, {2, 1}, {2, 0}]
    end

    test "returns the correct points for O tetromino" do
      assert Tetromino.points(:o) == [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
    end

    test "returns the correct points for S tetromino" do
      assert Tetromino.points(:s) == [{0, 1}, {1, 1}, {1, 0}, {2, 0}]
    end

    test "returns the correct points for T tetromino" do
      assert Tetromino.points(:t) == [{0, 1}, {1, 1}, {2, 1}, {1, 0}]
    end

    test "returns the correct points for Z tetromino" do
      assert Tetromino.points(:z) == [{0, 0}, {1, 0}, {1, 1}, {2, 1}]
    end
  end

  describe "translate/2" do
    test "translates the tetromino by the specified offset" do
      tetromino = Tetromino.new(:i)
      translated = Tetromino.translate(tetromino, {2, 3})

      assert translated.location == {6, 3}
      assert translated.shape == tetromino.shape
      assert translated.points == tetromino.points
      assert translated.rotation == tetromino.rotation
    end
  end

  describe "rotate/1" do
    test "rotates tetromino clockwise (increases rotation index)" do
      tetromino = Tetromino.new(:i)
      rotated = Tetromino.rotate(tetromino)

      assert rotated.rotation == 1
      assert rotated.shape == tetromino.shape
      assert rotated.points == tetromino.points
      assert rotated.location == tetromino.location
    end

    test "wraps rotation after 4 rotations" do
      tetromino = Tetromino.new(:i)
      
      once = Tetromino.rotate(tetromino)
      assert once.rotation == 1

      twice = Tetromino.rotate(once)
      assert twice.rotation == 2

      thrice = Tetromino.rotate(twice)
      assert thrice.rotation == 3

      four = Tetromino.rotate(thrice)
      assert four.rotation == 0
    end
  end

  describe "to_absolute_coordinates/1" do
    test "transforms points based on location and rotation" do
      # Test without rotation
      tetromino = %{shape: :i, points: [{0, 0}, {1, 0}, {2, 0}, {3, 0}], location: {5, 5}, rotation: 0}
      absolute = Tetromino.to_absolute_coordinates(tetromino)
      assert absolute == [{5, 5}, {6, 5}, {7, 5}, {8, 5}]

      # Test with 90-degree rotation (rotation = 1)
      tetromino = %{shape: :i, points: [{0, 0}, {1, 0}, {2, 0}, {3, 0}], location: {5, 5}, rotation: 1}
      absolute = Tetromino.to_absolute_coordinates(tetromino)
      assert absolute == [{5, 5}, {5, 6}, {5, 7}, {5, 8}]
    end
  end

  describe "rotate_points/2" do
    test "rotation = 0 returns the original points" do
      points = [{0, 0}, {1, 0}, {2, 0}]
      assert Tetromino.rotate_points(points, 0) == points
    end

    test "rotation = 1 rotates points 90 degrees clockwise" do
      points = [{0, 0}, {1, 0}, {0, 1}]
      rotated = Tetromino.rotate_points(points, 1)
      assert rotated == [{0, 0}, {0, 1}, {-1, 0}]
    end

    test "rotation = 2 rotates points 180 degrees" do
      points = [{0, 0}, {1, 0}, {0, 1}]
      rotated = Tetromino.rotate_points(points, 2)
      assert rotated == [{0, 0}, {-1, 0}, {0, -1}]
    end

    test "rotation = 3 rotates points 270 degrees clockwise" do
      points = [{0, 0}, {1, 0}, {0, 1}]
      rotated = Tetromino.rotate_points(points, 3)
      assert rotated == [{0, 0}, {0, -1}, {1, 0}]
    end
  end

  describe "color/1" do
    test "returns the correct color for each shape" do
      assert Tetromino.color(:i) == "cyan"
      assert Tetromino.color(:j) == "blue"
      assert Tetromino.color(:l) == "orange"
      assert Tetromino.color(:o) == "yellow"
      assert Tetromino.color(:s) == "green"
      assert Tetromino.color(:t) == "purple"
      assert Tetromino.color(:z) == "red"
    end
  end
end
