#!/usr/bin/env bash
set -euo pipefail

# repo-sync: Clone a GitHub repo and selectively copy submodules to ~/Development
# Usage: repo-sync [repository-url]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurable variables
CLONE_DIR="${REPO_SYNC_CLONE_DIR:-/tmp/repo-sync}"
TARGET_DIR="${REPO_SYNC_TARGET_DIR:-$HOME/Development}"

# Helper functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

cleanup() {
    if [[ -d "$CLONE_DIR" ]]; then
        read -p "Clean up clone directory ($CLONE_DIR)? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$CLONE_DIR"
            success "Cleaned up $CLONE_DIR"
        fi
    fi
}

# Trap for cleanup on exit
trap 'echo; warn "Script interrupted"' INT

# Get repository URL
if [[ $# -ge 1 ]]; then
    REPO_URL="$1"
else
    echo -e "${BLUE}Enter GitHub repository URL or user/repo:${NC}"
    read -p "> " REPO_URL
fi

# Handle shorthand notation (user/repo)
if [[ ! "$REPO_URL" =~ ^https?:// && ! "$REPO_URL" =~ ^git@ ]]; then
    REPO_URL="https://github.com/$REPO_URL"
fi

# Extract repo name for directory
REPO_NAME=$(basename "$REPO_URL" .git)
REPO_CLONE_PATH="$CLONE_DIR/$REPO_NAME"

info "Repository: $REPO_URL"
info "Clone destination: $REPO_CLONE_PATH"
info "Target directory: $TARGET_DIR"
echo

# Create clone directory
mkdir -p "$CLONE_DIR"

# Remove existing clone if present
if [[ -d "$REPO_CLONE_PATH" ]]; then
    warn "Directory already exists: $REPO_CLONE_PATH"
    read -p "Remove and re-clone? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$REPO_CLONE_PATH"
    else
        info "Using existing clone"
    fi
fi

# Clone repository with submodules
if [[ ! -d "$REPO_CLONE_PATH" ]]; then
    info "Cloning repository with submodules..."
    if ! git clone --recurse-submodules "$REPO_URL" "$REPO_CLONE_PATH"; then
        error "Failed to clone repository"
        exit 1
    fi
    success "Repository cloned successfully"
fi

# Change to repo directory
cd "$REPO_CLONE_PATH"

# Initialize submodules if not already done
git submodule update --init --recursive 2>/dev/null || true

# Find all submodules
info "Finding git submodules..."
SUBMODULES=$(git submodule status 2>/dev/null | awk '{print $2}' || true)

if [[ -z "$SUBMODULES" ]]; then
    warn "No submodules found in this repository"
    echo
    echo "Available options:"
    echo "  1. Copy the entire repository to $TARGET_DIR"
    echo "  2. Exit"
    read -p "Choose [1/2]: " -n 1 -r
    echo
    if [[ $REPLY == "1" ]]; then
        mkdir -p "$TARGET_DIR"
        cp -r "$REPO_CLONE_PATH" "$TARGET_DIR/"
        success "Copied entire repository to $TARGET_DIR/$REPO_NAME"
    fi
    cleanup
    exit 0
fi

# Count submodules
SUBMODULE_COUNT=$(echo "$SUBMODULES" | wc -l)
info "Found $SUBMODULE_COUNT submodule(s)"
echo

# Use fzf to select submodules
info "Select submodules to copy (TAB to select multiple, ENTER to confirm):"
echo

SELECTED=$(echo "$SUBMODULES" | fzf --multi \
    --header="Select submodules to copy to $TARGET_DIR" \
    --preview="ls -la $REPO_CLONE_PATH/{} 2>/dev/null || echo 'Directory not found'" \
    --preview-window=right:50% \
    --bind='ctrl-a:select-all,ctrl-d:deselect-all' \
    --prompt="Submodules > " || true)

if [[ -z "$SELECTED" ]]; then
    warn "No submodules selected"
    cleanup
    exit 0
fi

# Show selection summary
echo
info "Selected submodules:"
echo "$SELECTED" | while read -r submodule; do
    echo "  - $submodule"
done
echo

# Confirm copy
SELECTED_COUNT=$(echo "$SELECTED" | wc -l)
read -p "Copy $SELECTED_COUNT submodule(s) to $TARGET_DIR? [y/N]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Copy cancelled"
    cleanup
    exit 0
fi

# Create target directory
mkdir -p "$TARGET_DIR"

# Copy selected submodules
info "Copying submodules..."
echo "$SELECTED" | while read -r submodule; do
    SUBMODULE_NAME=$(basename "$submodule")
    SOURCE_PATH="$REPO_CLONE_PATH/$submodule"
    DEST_PATH="$TARGET_DIR/$SUBMODULE_NAME"

    if [[ -d "$DEST_PATH" ]]; then
        warn "Skipping $SUBMODULE_NAME (already exists at $DEST_PATH)"
        continue
    fi

    cp -r "$SOURCE_PATH" "$DEST_PATH"
    success "Copied $SUBMODULE_NAME to $DEST_PATH"
done

echo
success "All selected submodules copied to $TARGET_DIR"

# Cleanup
cleanup

echo
info "Done!"
