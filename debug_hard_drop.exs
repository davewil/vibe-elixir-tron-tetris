# Test specifically the J tetromino case that's failing
board = TronTetris.Game.Board.new()
j_tetromino = TronTetris.Game.Tetromino.new(:j)
j_board = %{board | active_tetromino: j_tetromino}

IO.puts("Testing J tetromino hard_drop")
IO.puts("Original J tetromino: #{inspect(j_board.active_tetromino)}")

result_board = TronTetris.Game.Board.hard_drop(j_board)
IO.puts("After hard_drop: #{inspect(result_board.active_tetromino)}")
IO.puts("Are they equal? #{j_board.active_tetromino == result_board.active_tetromino}")

# Let's also test with the exact same tetromino twice to see if there's an issue
board2 = TronTetris.Game.Board.new()
j_tetromino2 = TronTetris.Game.Tetromino.new(:j)
j_board2 = %{board2 | active_tetromino: j_tetromino2, next_tetromino: j_tetromino2}

IO.puts("\n--- Testing with same J tetromino as next ---")
IO.puts("Original: #{inspect(j_board2.active_tetromino)}")
IO.puts("Next: #{inspect(j_board2.next_tetromino)}")

result_board2 = TronTetris.Game.Board.hard_drop(j_board2)
IO.puts("After hard_drop: #{inspect(result_board2.active_tetromino)}")
IO.puts("Are they equal? #{j_board2.active_tetromino == result_board2.active_tetromino}")
