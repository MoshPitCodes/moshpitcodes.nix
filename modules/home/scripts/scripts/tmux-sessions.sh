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
# Each session gets 2 windows:
#   - Window 1 (code): Opens the directory
#   - Window 2 (claude): Runs claude-code
#
# Format: "session_name|path"
# Add your sessions here:
SESSIONS=(
    "moshpitcodes-nix|/mnt/f/Coding/moshpitcodes/moshpitcodes.nix"
    "moshpitcodes-homelab|/mnt/f/Coding/moshpitcodes/moshpitcodes.homelab"
    "moshpitcodes-wsl2|/mnt/f/Coding/moshpitcodes/moshpitcodes.wsl2"
    "moshpitcodes-template|/mnt/f/Coding/moshpitcodes/moshpitcodes.template"
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

show_help() {
    cat << 'EOF'
tmux-sessions - Create and manage predefined tmux sessions

USAGE:
    tmux-sessions [OPTIONS] [SESSION_NAME]

OPTIONS:
    --list, -l      List configured sessions and their status
    --help, -h      Show this help message
    --create-only   Create sessions without attaching

ARGUMENTS:
    SESSION_NAME    Optional session name to attach to after creation

EXAMPLES:
    tmux-sessions                  # Create all sessions, show list
    tmux-sessions moshpitcodes.nix # Create all sessions, attach to session
    tmux-sessions --list           # Show configured sessions
    tmux-sessions --create-only    # Create sessions without attaching

CONFIGURATION:
    Edit the SESSIONS array in this script to add/modify sessions.
    Format: "session_name|path"

    Each session is created with 2 windows:
      - Window 1 (code):   Shell in the project directory
      - Window 2 (claude): claude-code running in the project directory
EOF
}

list_sessions() {
    echo "Configured sessions:"
    echo "===================="
    printf "%-25s %-50s %s\n" "SESSION" "PATH" "STATUS"
    printf "%-25s %-50s %s\n" "-------" "----" "------"

    for entry in "${SESSIONS[@]}"; do
        IFS='|' read -r name path <<< "$entry"
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

        # Create session with first window named 'code'
        tmux new-session -d -s "$name" -n "code" -c "$path"

        # Create second window named 'claude' and run claude-code
        tmux new-window -t "$name" -n "claude" -c "$path"
        tmux send-keys -t "$name:claude.0" "claude" C-m

        # Select the first window by default
        tmux select-window -t "$name:code"

        echo "Created session: $name (in $path) with windows: code, claude"
    else
        echo "Session exists: $name"
    fi
}

create_all_sessions() {
    for entry in "${SESSIONS[@]}"; do
        IFS='|' read -r name path <<< "$entry"
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
            --help|-h)
                show_help
                exit 0
                ;;
            --list|-l)
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
