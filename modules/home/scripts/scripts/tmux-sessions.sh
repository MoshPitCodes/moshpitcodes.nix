#!/usr/bin/env bash

# tmux-sessions - Create and manage predefined tmux sessions
#
# Usage:
#   tmux-sessions              # Create all sessions, list them
#   tmux-sessions <name>       # Create all sessions, attach to <name>
#   tmux-sessions --list       # List configured sessions
#   tmux-sessions --help       # Show help

set -euo pipefail

# =============================================================================
# SESSION CONFIGURATION
# =============================================================================
# Two predefined sessions:
#   1. "dev" - Development session with two panes in ~/Development
#   2. "monitor" - Monitoring session with btop (left) and shell (right)
#
# Format: "session_name|path|layout_type"
DEVELOPMENT_DIR="$HOME/Development"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

discover_sessions() {
  # Define exactly two sessions
  printf '%s\n' "dev|$DEVELOPMENT_DIR|dev" "monitor|$DEVELOPMENT_DIR|monitor"
}

show_help() {
  cat <<'EOF'
tmux-sessions - Create and manage predefined tmux sessions

USAGE:
    tmux-sessions [OPTIONS] [SESSION_NAME]

OPTIONS:
    --list, -l      List configured sessions and their status
    --help, -h      Show this help message
    --create-only   Create sessions without attaching

ARGUMENTS:
    SESSION_NAME    Optional session name to attach to after creation (dev or monitor)

EXAMPLES:
    tmux-sessions          # Create all sessions, show list
    tmux-sessions dev      # Create all sessions, attach to dev
    tmux-sessions monitor  # Create all sessions, attach to monitor
    tmux-sessions --list   # Show configured sessions

CONFIGURATION:
    Two predefined sessions:
    
    1. "dev" session - Development workspace
       - Left pane:  Shell in ~/Development
       - Right pane: Shell in ~/Development

    2. "monitor" session - System monitoring
       - Left pane:  btop (system monitor)
       - Right pane: Shell in ~/Development
EOF
}

list_sessions() {
  echo "Configured sessions:"
  echo "===================="
  printf "%-25s %-50s %s\n" "SESSION" "PATH" "STATUS"
  printf "%-25s %-50s %s\n" "-------" "----" "------"

  # Get discovered sessions
  local -a discovered_sessions
  mapfile -t discovered_sessions < <(discover_sessions)

  for entry in "${discovered_sessions[@]}"; do
    IFS='|' read -r name path layout <<<"$entry"
    # Expand tilde
    path="${path/#\~/$HOME}"

    if tmux has-session -t "$name" 2>/dev/null; then
      status="running"
    else
      status="stopped"
    fi

    printf "%-25s %-50s %s\n" "$name" "$path" "$status"
  done

  echo ""
  echo "Active tmux sessions:"
  echo "====================="
  tmux list-sessions 2>/dev/null || echo "(none)"
}

ensure_session() {
  local name=$1
  local path=$2
  local layout=$3

  # Expand tilde in path
  path="${path/#\~/$HOME}"

  if ! tmux has-session -t "$name" 2>/dev/null; then
    # Verify path exists
    if [[ ! -d "$path" ]]; then
      echo "Warning: Path '$path' does not exist for session '$name', using home directory"
      path="$HOME"
    fi

    # Create session with a single window in the project directory
    tmux new-session -d -s "$name" -c "$path"

    if [[ "$layout" == "monitor" ]]; then
      # Monitor session: btop (left), shell (right)
      tmux split-window -h -t "${name}:1" -c "$path"
      # Run btop in left pane (pane 1)
      tmux send-keys -t "${name}:1.1" "btop" C-m
      # Right pane (pane 2) is already a shell in $path
      # Select right pane (shell) as active
      tmux select-pane -t "${name}:1.2"
      echo "Created session: $name (in $path) with panes: btop, shell"
    else
      # Dev session: shell (left), shell (right)
      tmux split-window -h -t "${name}:1" -c "$path"
      # Both panes are shells in $path
      # Select the left pane as the active pane
      tmux select-pane -t "${name}:1.1"
      echo "Created session: $name (in $path) with panes: shell, shell"
    fi
  else
    echo "Session exists: $name"
  fi
}

create_all_sessions() {
  # Get discovered sessions
  local -a discovered_sessions
  mapfile -t discovered_sessions < <(discover_sessions)

  for entry in "${discovered_sessions[@]}"; do
    IFS='|' read -r name path layout <<<"$entry"
    ensure_session "$name" "$path" "$layout"
  done
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  local attach_to=""
  local create_only=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --help | -h)
      show_help
      exit 0
      ;;
    --list | -l)
      list_sessions
      exit 0
      ;;
    --create-only)
      create_only=true
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
    *)
      # Convert dots to dashes in session name for consistency
      attach_to="${1//\./-}"
      shift
      ;;
    esac
  done

  # Create all configured sessions
  create_all_sessions

  echo ""

  # Handle attachment
  if [[ -n "$attach_to" ]]; then
    if tmux has-session -t "$attach_to" 2>/dev/null; then
      if [[ -z "${TMUX:-}" ]]; then
        exec tmux attach -t "$attach_to"
      else
        tmux switch-client -t "$attach_to"
      fi
    else
      echo "Error: Session '$attach_to' does not exist"
      echo "Available sessions:"
      tmux list-sessions
      exit 1
    fi
  elif [[ "$create_only" == false && -z "${TMUX:-}" ]]; then
    echo "Available sessions:"
    tmux list-sessions 2>/dev/null || echo "(none)"
    echo ""
    echo "Use 'tmux-sessions <name>' to attach to a session"
  fi
}

main "$@"
