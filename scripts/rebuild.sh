#!/usr/bin/env bash
# Script to rebuild NixOS configuration

set -e

# Resolve to repository root (parent of scripts/ directory)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Allow host to be specified as first argument, default to laptop
HOST="${1:-laptop}"

echo "Clearing Nix caches..."
rm -rf ~/.cache/nix

echo "Garbage collecting old builds (requires sudo password)..."
sudo nix-collect-garbage -d

echo "Rebuilding system configuration for host: $HOST"
sudo nixos-rebuild switch --flake "$REPO_ROOT#$HOST" --impure
# sudo nixos-rebuild switch --flake .#wsl --impure --option eval-cache false

echo "Done!"
