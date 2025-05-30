defmodule TronTetrisWeb.Live.Hooks.SoundHooks do
  @moduledoc """
  Hooks for playing sounds in the Tetris game.
  These hooks will inject JavaScript to play sounds on game events.
  """
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end
