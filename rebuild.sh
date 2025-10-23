#!/usr/bin/env bash
# Script to rebuild NixOS configuration

set -e

echo "Clearing Nix caches..."
rm -rf ~/.cache/nix

echo "Garbage collecting old builds (requires sudo password)..."
sudo nix-collect-garbage -d

echo "Rebuilding system configuration..."
sudo nixos-rebuild switch --flake ".#laptop" --impure

echo "Done!"
