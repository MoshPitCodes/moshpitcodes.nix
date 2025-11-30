#!/usr/bin/env bash
# Copy project contents to ~/moshpitcodes.nix
# Excludes patterns defined in .rsyncignore

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
SOURCE_DIR="$(get_repo_root)"
DEST_DIR="$HOME/moshpitcodes.nix"
RSYNC_IGNORE="$SOURCE_DIR/.rsyncignore"
DRY_RUN=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; then
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Copy project to ~/moshpitcodes.nix"
            echo ""
            echo "Options:"
            echo "  -n, --dry-run    Show what would be copied without copying"
            echo "  -v, --verbose    Show detailed rsync output"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate prerequisites
if ! command -v rsync &> /dev/null; then
    suggest_install rsync
fi
require_file "$RSYNC_IGNORE" "Missing .rsyncignore file in repository root"

# Show what we're doing
info "Copying project:"
echo "  Source:      $SOURCE_DIR"
echo "  Destination: $DEST_DIR"
[[ $DRY_RUN == true ]] && echo "  Mode:        ${YELLOW}DRY RUN${NORMAL}"
echo ""

# Create destination if it doesn't exist
[[ $DRY_RUN == false ]] && mkdir -p "$DEST_DIR"

# Build rsync command
RSYNC_OPTS=(-a --delete "--exclude-from=$RSYNC_IGNORE")
[[ $DRY_RUN == true ]] && RSYNC_OPTS+=(--dry-run)
[[ $VERBOSE == true ]] && RSYNC_OPTS+=(-v) || RSYNC_OPTS+=(--info=progress2)

# Execute rsync
if rsync "${RSYNC_OPTS[@]}" "$SOURCE_DIR/" "$DEST_DIR/"; then
    [[ $DRY_RUN == false ]] && info "Copy completed successfully"
else
    error "rsync failed with exit code $?"
fi

# Fix line endings (only if not dry-run)
if [[ $DRY_RUN == false ]]; then
    info "Fixing line endings for shell scripts and Nix files..."
    find "$DEST_DIR" -type f \( -name "*.sh" -o -name "*.nix" -o -name ".zshrc" \) \
        -exec sed -i 's/\r$//' {} + 2>/dev/null || warning "Some files failed line ending conversion"
fi

[[ $DRY_RUN == false ]] && info "Project copied to: $DEST_DIR"
