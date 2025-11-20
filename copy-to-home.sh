#!/usr/bin/env bash
# Script to copy project contents to ~/moshpitcodes.nix
# Excludes git and vscode files/folders

set -e

# Source and destination directories
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/moshpitcodes.nix"

echo "Copying project from:"
echo "  Source: $SOURCE_DIR"
echo "  Destination: $DEST_DIR"
echo ""

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Use rsync to copy contents, excluding git and vscode files
rsync -av \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='.gitmodules' \
  --exclude='.gitattributes' \
  --exclude='.vscode/' \
  --exclude='.vscode-test/' \
  --delete \
  "$SOURCE_DIR/" "$DEST_DIR/"

echo ""
echo "Fixing line endings in shell config files..."
# Fix CRLF line endings in shell configuration files
for file in "$DEST_DIR/.zshrc" "$DEST_DIR"/**/*.sh "$DEST_DIR"/**/*.nix; do
  if [ -f "$file" ]; then
    sed -i 's/\r$//' "$file" 2>/dev/null || true
  fi
done

echo "✓ Copy complete!"
echo "Project contents copied to: $DEST_DIR"
