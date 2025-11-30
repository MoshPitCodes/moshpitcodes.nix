#!/usr/bin/env bash
# Rebuild NixOS configuration with optional garbage collection

# Ensure we're running in bash
if [ -z "$BASH_VERSION" ]; then
    echo "ERROR: This script requires bash. Run with: bash $0" >&2
    exit 1
fi

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Configuration
REPO_ROOT="$(get_repo_root)"
HOST="${1:-laptop}"
CLEAR_CACHE=false
RUN_GC=false
DRY_RUN=false

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --clear-cache)
            CLEAR_CACHE=true
            shift
            ;;
        --gc|--garbage-collect)
            RUN_GC=true
            shift
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [HOST] [OPTIONS]"
            echo "Rebuild NixOS configuration"
            echo ""
            echo "Arguments:"
            echo "  HOST                 Host configuration (default: laptop)"
            echo ""
            echo "Options:"
            echo "  --clear-cache        Clear ~/.cache/nix before rebuild"
            echo "  --gc                 Run garbage collection before rebuild"
            echo "  -n, --dry-run        Show what would be built without building"
            echo "  -h, --help           Show this help message"
            echo ""
            echo "Available hosts:"
            ls -1 "$REPO_ROOT/hosts" | sed 's/^/  - /'
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"
[[ $# -gt 0 ]] && HOST="$1"

# Validate prerequisites
require_not_root
require_sudo_available
require_directory "$REPO_ROOT/hosts/$HOST" "Host configuration not found: $HOST"

# Show configuration
info "Rebuild configuration:"
echo "  Host:        $HOST"
echo "  Flake:       $REPO_ROOT#$HOST"
[[ $CLEAR_CACHE == true ]] && echo "  Clear cache: ${YELLOW}yes${NORMAL}"
[[ $RUN_GC == true ]] && echo "  Run GC:      ${YELLOW}yes${NORMAL}"
[[ $DRY_RUN == true ]] && echo "  Mode:        ${YELLOW}DRY RUN${NORMAL}"
echo ""

# Clear cache if requested
if [[ $CLEAR_CACHE == true ]]; then
    if confirm "Clear Nix cache (~/.cache/nix)?"; then
        info "Clearing Nix cache..."
        rm -rf ~/.cache/nix
    fi
fi

# Run garbage collection if requested
if [[ $RUN_GC == true ]]; then
    if confirm "Run garbage collection (requires sudo)?"; then
        info "Garbage collecting old builds..."
        sudo nix-collect-garbage -d
    fi
fi

# Build the system
info "Rebuilding system configuration..."
REBUILD_OPTS=(switch "--flake" "$REPO_ROOT#$HOST")
[[ $DRY_RUN == true ]] && REBUILD_OPTS=(build "--flake" "$REPO_ROOT#$HOST")

if sudo nixos-rebuild "${REBUILD_OPTS[@]}"; then
    info "Rebuild completed successfully!"
else
    error "nixos-rebuild failed with exit code $?"
fi
