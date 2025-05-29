defmodule TronTetrisWeb.Auth.LoginLive do
  @moduledoc """
  LiveView for player login.
  """
  
  use TronTetrisWeb, :live_view
  alias TronTetris.Accounts
  
  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:page_title, "Login")
      |> assign(:current_player, Map.get(session, "player_id"))
      |> assign(:changeset, %{username: "", password: ""})
      |> assign(:error_message, nil)
    
    {:ok, socket}
  end
  
  @impl true
  def handle_event("login", %{"username" => username, "password" => password}, socket) do
    case Accounts.authenticate_player(username, password) do
      {:ok, player} ->
        {:noreply,
          socket
          |> put_flash(:info, "Welcome back, #{player.username}!")
          # Store player ID in the session
          |> redirect(to: ~p"/tetris?player_id=#{player.id}")}
      
      {:error, _reason} ->
        {:noreply,
          socket
          |> assign(:error_message, "Invalid username or password")
          |> put_flash(:error, "Invalid username or password")}
    end
  end
  
  @impl true
  def handle_event("register", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/register")}
  end
  
  @impl true
  def handle_event("validate", %{"username" => username, "password" => password}, socket) do
    changeset = %{username: username, password: password}
    {:noreply, assign(socket, :changeset, changeset)}
  end
end
