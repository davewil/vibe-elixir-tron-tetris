defmodule TronTetrisWeb.Auth.RegisterLive do
  @moduledoc """
  LiveView for player registration.
  """
  
  use TronTetrisWeb, :live_view
  alias TronTetris.Accounts
  alias TronTetris.Accounts.Player
  alias Ecto.Changeset
  
  @impl true
  def mount(_params, _session, socket) do
    changeset = Changeset.change(%Player{})
    
    socket =
      socket
      |> assign(:page_title, "Register")
      |> assign(:changeset, changeset)
    
    {:ok, socket}
  end
  
  @impl true
  def handle_event("validate", %{"player" => params}, socket) do
    changeset =
      %Player{}
      |> Player.changeset(params)
      |> Map.put(:action, :validate)
    
    {:noreply, assign(socket, :changeset, changeset)}
  end
    @impl true
  def handle_event("register", %{"player" => params}, socket) do
    case Accounts.create_player(params) do
      {:ok, player} ->
        {:noreply,
          socket
          |> put_flash(:info, "Account created successfully!")
          # Store player ID in the query parameters instead of session
          |> redirect(to: ~p"/tetris?player_id=#{player.id}")}
      
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
  
  @impl true
  def handle_event("back_to_login", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/login")}
  end
end
