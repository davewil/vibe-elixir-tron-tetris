defmodule TronTetris.Repo do
  use Ecto.Repo,
    otp_app: :tron_tetris,
    adapter: Ecto.Adapters.SQLite3
end
