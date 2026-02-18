#!/usr/bin/env bash

# tmux-sessions - Create and manage tmux sessions with simple 2-panel layout
#
# Usage:
#   tmux-sessions <session-name>   # Create/attach to session with 2 panels
#   tmux-sessions --list           # List active sessions
#   tmux-sessions --help           # Show help

set -euo pipefail

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

show_help() {
  cat <<'EOF'
tmux-sessions - Create and manage tmux sessions with simple 2-panel layout

USAGE:
    tmux-sessions <session-name>
    tmux-sessions --help
    tmux-sessions --list

DESCRIPTION:
    Create a tmux session with 2 horizontal panels (left/right split).
    If the session already exists, attach to it.

OPTIONS:
    --help, -h      Show this help message
    --list, -l      List all active tmux sessions

ARGUMENTS:
    session-name    Name for the tmux session (required)
                    Must contain only: letters, numbers, hyphens, underscores
                    No spaces allowed (use hyphens instead)

EXAMPLES:
    tmux-sessions backend      # Create/attach to 'backend' session
    tmux-sessions frontend     # Create/attach to 'frontend' session
    tmux-sessions infra        # Create/attach to 'infra' session
    tmux-sessions my-project   # Create/attach to 'my-project' session
    tmux-sessions --list       # List all active sessions

SESSION NAMING RULES:
    - Alphanumeric characters, hyphens (-), and underscores (_) only
    - No spaces (use hyphens instead: my-session, not "my session")
    - Case-sensitive (backend != Backend)

PANEL LAYOUT:
    All sessions are created with 2 horizontal panels:
    - Left panel:  Shell (active by default)
    - Right panel: Shell

MIGRATION NOTE:
    If you previously used predefined "dev" or "monitor" sessions:
    - Run: tmux-sessions dev      (creates simple 2-panel layout)
    - Run: tmux-sessions monitor  (creates simple 2-panel layout)
    - Note: btop and other commands must be run manually after creation
EOF
}

list_sessions() {
  echo "Active tmux sessions:"
  echo "===================="
  if ! tmux list-sessions 2>/dev/null; then
    echo "(none)"
    return 1
  fi
}

validate_session_name() {
  local name="$1"

  # Check for empty string
  if [[ -z "$name" ]]; then
    echo "Error: Session name cannot be empty."
    echo ""
    show_help
    exit 1
  fi

  # Check for spaces
  if [[ "$name" =~ [[:space:]] ]]; then
    echo "Error: Session name cannot contain spaces."
    echo "Suggestion: Use hyphens instead (e.g., 'my-session')"
    exit 1
  fi

  # Check for invalid characters (only allow alphanumeric, hyphens, underscores)
  if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Session name contains invalid characters."
    echo "Allowed characters: letters, numbers, hyphens (-), underscores (_)"
    echo "Your input: '$name'"
    exit 1
  fi
}

create_session() {
  local name="$1"

  # Check if session already exists
  if tmux has-session -t "$name" 2>/dev/null; then
    echo "Session '$name' already exists. Attaching..."

    # Attach or switch depending on whether we're already in tmux
    if [[ -z "${TMUX:-}" ]]; then
      exec tmux attach-session -t "$name"
    else
      tmux switch-client -t "$name"
    fi
  else
    echo "Creating session '$name' with 2 horizontal panels..."

    # Create new session (detached)
    tmux new-session -d -s "$name"

    # Split window horizontally (creates left and right panels)
    tmux split-window -h -t "$name"

    # Select left pane as active (window 1, pane 1)
    tmux select-pane -t "$name:1.1"

    # Attach to the session
    if [[ -z "${TMUX:-}" ]]; then
      exec tmux attach-session -t "$name"
    else
      tmux switch-client -t "$name"
    fi
  fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  # Parse arguments
  case "${1:-}" in
    --help|-h)
      show_help
      exit 0
      ;;
    --list|-l)
      list_sessions
      exit $?
      ;;
    "")
      echo "Error: No session name provided."
      echo ""
      show_help
      exit 1
      ;;
    -*)
      echo "Error: Unknown option: $1"
      echo ""
      show_help
      exit 1
      ;;
    *)
      # Validate and create/attach to session
      validate_session_name "$1"
      create_session "$1"
      ;;
  esac
}

main "$@"
