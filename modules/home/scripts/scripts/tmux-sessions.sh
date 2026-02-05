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
#   1. dev - Development session with claude and terminal
#   2. monitor - System monitoring session
#
DEVELOPMENT_DIR="$HOME/Development"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

get_sessions() {
  # Return static list of 2 sessions
  echo "dev|$DEVELOPMENT_DIR"
  echo "nas|/mnt/ugreen-nas"
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
    SESSION_NAME    Optional session name to attach to after creation
                    Available: dev, nas

EXAMPLES:
    tmux-sessions           # Create all sessions, show list
    tmux-sessions dev       # Create all sessions, attach to 'dev'
    tmux-sessions nas       # Create all sessions, attach to 'nas'
    tmux-sessions --list    # Show configured sessions
    tmux-sessions --create-only    # Create sessions without attaching

CONFIGURATION:
    Two predefined sessions are created:

    1. dev - Development session (in ~/Development)
       - Left pane:  opencode running in ~/Development
       - Right pane: Shell in ~/Development

    2. nas - NAS monitoring session (in /mnt/ugreen-nas)
       - Left pane:  btop
       - Right pane: Shell in /mnt/ugreen-nas
EOF
}

list_sessions() {
  echo "Configured sessions:"
  echo "===================="
  printf "%-25s %-50s %s\n" "SESSION" "PATH" "STATUS"
  printf "%-25s %-50s %s\n" "-------" "----" "------"

  # Get static sessions
  local -a sessions
  mapfile -t sessions < <(get_sessions)

  for entry in "${sessions[@]}"; do
    IFS='|' read -r name path <<<"$entry"
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

  # Expand tilde in path
  path="${path/#\~/$HOME}"

  if ! tmux has-session -t "$name" 2>/dev/null; then
    # Verify path exists
    if [[ ! -d "$path" ]]; then
      echo "Warning: Path '$path' does not exist for session '$name', using home directory"
      path="$HOME"
    fi

    # Create session with a single window
    tmux new-session -d -s "$name" -c "$path"

    if [[ "$name" == "dev" ]]; then
      # Dev session: 2 panes (opencode left, terminal right)
      # Left pane (pane 1) runs opencode
      tmux send-keys -t "${name}:1.1" "opencode" C-m

      # Create right pane (pane 2) with shell (33% width, making left pane 67%)
      tmux split-window -h -p 33 -t "${name}:1" -c "$path"

      # Select the left pane (claude) as the active pane
      tmux select-pane -t "${name}:1.1"

      echo "Created session: $name (in $path) with panes: opencode, shell"
    elif [[ "$name" == "nas" ]]; then
      # NAS session: 4 panes (btop top-left, terminals in other 3)
      # Top-left pane (pane 1) runs btop
      tmux send-keys -t "${name}:1.1" "btop" C-m

      # Create top-right pane (pane 2) with shell in ~/Development
      tmux split-window -h -t "${name}:1" -c "$HOME/Development"

      # Create bottom-left pane (pane 3) with shell in /mnt/ugreen-nas
      tmux split-window -v -t "${name}:1.1" -c "/mnt/ugreen-nas"

      # Create bottom-right pane (pane 4) with shell in ~/Development
      tmux split-window -v -t "${name}:1.2" -c "$HOME/Development"

      # Select the top-left pane (btop) as the active pane
      tmux select-pane -t "${name}:1.1"

      echo "Created session: $name (in $path) with panes: btop (top-left), bottom-left (/mnt/ugreen-nas), 2 terminals in ~/Development"
    fi
  else
    echo "Session exists: $name"
  fi
}

create_all_sessions() {
  # Get static sessions
  local -a sessions
  mapfile -t sessions < <(get_sessions)

  for entry in "${sessions[@]}"; do
    IFS='|' read -r name path <<<"$entry"
    ensure_session "$name" "$path"
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
      attach_to="$1"
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
