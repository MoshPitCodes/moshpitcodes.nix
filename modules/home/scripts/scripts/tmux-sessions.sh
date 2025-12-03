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
# Standard sessions get 1 window with 2 panes:
#   - Left pane: Shell in the project directory
#   - Right pane: claude-code running in the project directory
#
# Special session (moshpitcodes-devops) gets 1 window with 3 panes:
#   - Left pane: Shell in home directory
#   - Top-right pane: gemini
#   - Bottom-right pane: bashtop
#
# Format: "session_name|path"
# Add your sessions here:
SESSIONS=(
    "moshpitcodes-nix|/mnt/f/Coding/moshpitcodes/moshpitcodes.nix"
    "moshpitcodes-homelab|/mnt/f/Coding/moshpitcodes/moshpitcodes.homelab"
    "moshpitcodes-wsl2|/mnt/f/Coding/moshpitcodes/moshpitcodes.wsl2"
    "moshpitcodes-template|/mnt/f/Coding/moshpitcodes/moshpitcodes.template"
    "moshpitcodes-devops|~"
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

    Standard sessions are created with 1 window containing 2 panes:
      - Left pane:  Shell in the project directory
      - Right pane: claude-code running in the project directory

    Special session (moshpitcodes-devops) has 1 window with 3 panes:
      - Left pane:       Shell in home directory
      - Top-right pane:  gemini
      - Bottom-right:    bashtop
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

        # Create session with a single window in the project directory
        tmux new-session -d -s "$name" -c "$path"

        # Special layout for devops session: 3 panes (shell left, gemini top-right, bashtop bottom-right)
        if [[ "$name" == "moshpitcodes-devops" ]]; then
            # Split horizontally: left pane (shell), right pane
            tmux split-window -h -t "${name}:1" -c "$path"
            # Split right pane vertically: top (gemini), bottom (bashtop)
            tmux split-window -v -t "${name}:1.2" -c "$path"
            # Run gemini in top-right pane (pane 2)
            tmux send-keys -t "${name}:1.2" "gemini" C-m
            # Run bashtop in bottom-right pane (pane 3)
            tmux send-keys -t "${name}:1.3" "bashtop" C-m
            # Select left pane (shell) as active
            tmux select-pane -t "${name}:1.1"
            echo "Created session: $name (in $path) with panes: shell, gemini, bashtop"
        else
            # Standard layout: 2 panes (shell left, claude right)
            # Split the window horizontally (left/right panes)
            # Note: Using base-index 1 (configured in tmux.nix), so first window is :1
            # Left pane (pane 1) is already the shell in the project directory
            # Create right pane (pane 2) and run claude-code
            tmux split-window -h -t "${name}:1" -c "$path"
            tmux send-keys -t "${name}:1.2" "claude" C-m

            # Select the left pane (shell) as the active pane
            tmux select-pane -t "${name}:1.1"

            echo "Created session: $name (in $path) with panes: shell, claude"
        fi
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
