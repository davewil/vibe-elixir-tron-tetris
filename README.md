# TronTetris

## Executive Summary

TronTetris is a web-based Tetris game built with the Phoenix LiveView framework in Elixir. It aims to provide a classic Tetris experience with a "Tron-like" aesthetic. The game features standard Tetris mechanics including piece movement (left, right, drop), rotation, hard drop, line clearing, scoring, and level progression. Player authentication and leaderboards are also implemented. The project is currently in a playable state, with core game logic and user interface in place.

## Getting Started

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## API Documentation

The application primarily uses Phoenix LiveView for real-time user interaction. Key LiveView routes are defined in `lib/tron_tetris_web/router.ex`:

* `/` or `/tetris`: Main game interface (`TronTetrisWeb.TetrisLive`).
* `/leaderboard`: Displays the game leaderboard (`TronTetrisWeb.LeaderboardLive`).
* `/login`: User login page (`TronTetrisWeb.Auth.LoginLive`).
* `/register`: User registration page (`TronTetrisWeb.Auth.RegisterLive`).

No traditional REST API endpoints are exposed for direct consumption as the game logic is handled via LiveView events and GenServers.

## Workflow Diagrams

### Game Logic Flow (Simplified)

```mermaid
graph TD
    A["Game Starts/New Piece"] --> B{"Piece Falling"};
    B -- User Input --> C{"Move/Rotate"};
    C --> B;
    B -- Tick --> D{"Attempt Move Down"};
    D -- Valid Position --> B;
    D -- Invalid Position/Collision --> E{"Land Piece"};
    E --> F{"Check for Line Clears"};
    F -- Lines Cleared --> G["Update Score/Level, Shift Blocks"];
    G --> H{"Spawn New Piece"};
    F -- No Lines Cleared --> H;
    H -- Valid Spawn --> B;
    H -- Invalid Spawn (Game Over) --> I["Game Over State"];
```

### User Interaction Flow (LiveView)

```mermaid
graph TD
    J["User Visits /tetris"] --> K["TetrisLive Mounts"];
    K --> L["Game Server (GenServer) Started and State Loaded"];
    L --> M["Game Board Rendered"];
    M -- User Key Press (e.g., Arrow Keys, Space) --> N{"keydown Event (TetrisLive)"};
    N --> O["Server.handle_cast (e.g., move_left, rotate, drop, toggle_pause)"];
    O --> P{"Board Module Updates Game State"};
    P --> Q["PubSub Broadcasts :tetris_update"];
    Q --> R{"handle_info :tetris_update (TetrisLive)"};
    R --> M;
    M -->|"User Clicks &quot;New Game&quot;"| S{"handle_event &quot;new_game&quot; (TetrisLive)"};
    S --> T["Server.new_game"];
    T --> P;
```

## Learn more

* Official website: <https://www.phoenixframework.org/>
* Guides: <https://hexdocs.pm/phoenix/overview.html>
* Docs: <https://hexdocs.pm/phoenix>
* Forum: <https://elixirforum.com/c/phoenix-forum>
* Source: <https://github.com/phoenixframework/phoenix>
