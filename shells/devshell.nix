{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "general-dev";

  buildInputs = with pkgs; [
    # Version Control
    git
    gh # GitHub CLI

    # Nix Tools
    nixd # Nix LSP
    nixfmt # Nix formatter
    nix-prefetch-github # Fetch GitHub repositories
    deadnix # Find dead Nix code
    statix # Lint Nix files

    # Shell Tools
    bash
    zsh
    shfmt # Shell formatter

    # Text Processing
    jq # JSON processor
    yq # YAML processor
    ripgrep # Fast text search

    # Build Tools
    gnumake
    cmake
    pkg-config

    # Compression
    gzip
    bzip2
    xz
    zip
    unzip

    # Network Tools
    curl
    wget
    netcat

    # Development Utilities
    direnv # Load environment variables from .envrc
    tree # Directory tree viewer
    btop # Process viewer
  ];

  shellHook = ''
    echo "╭─────────────────────────────────────────────────────────────────╮"
    echo "│                                                                 │"
    echo "│  🛠️  General Development Environment                            │"
    echo "│                                                                 │"
    echo "│  NixOS Configuration Development Shell                          │"
    echo "│                                                                 │"
    echo "╰─────────────────────────────────────────────────────────────────╯"
    echo ""
    echo "📦 Environment Details:"
    echo "   Git:     $(git --version | cut -d' ' -f3)"
    echo "   Nix:     $(nix --version | cut -d' ' -f3)"
    echo "   Shell:   $SHELL"
    echo ""
    echo "🛠️  Available Tools:"
    echo "   • Version Control: git, gh"
    echo "   • Nix Tools: nixd, nixfmt, deadnix, statix"
    echo "   • Text Processing: jq, yq, ripgrep"
    echo "   • Build Tools: make, cmake, pkg-config"
    echo "   • Shell Tools: bash, zsh, shfmt"
    echo ""
    echo "📝 Common Commands:"
    echo "   nix flake check              # Validate flake configuration"
    echo "   nix flake update             # Update flake inputs"
    echo "   nixfmt **/*.nix    # Format Nix files"
    echo "   deadnix .                    # Find dead Nix code"
    echo "   statix check .               # Lint Nix files"
    echo "   scripts/rebuild.sh [host]    # Rebuild system configuration"
    echo ""
    echo "🎯 Quick Actions:"
    echo "   • Build WSL tarball: nix build .#wsl-distro"
    echo "   • Test configuration: nix eval .#nixosConfigurations.wsl.config.system.build.toplevel.drvPath"
    echo "   • Format all files: find . -name '*.nix' -exec nixfmt {} +"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Set up helpful aliases
    alias nix-fmt="find . -name '*.nix' -exec nixfmt {} +"
    alias nix-check="nix flake check --show-trace"
    alias nix-update="nix flake update"
    alias rebuild="scripts/rebuild.sh"
    alias build-wsl="nix build .#wsl-distro"
  '';

  # Environment variables
  NIX_SHELL_NAME = "general-dev";

  # Enable flakes and nix-command for convenience
  NIX_CONFIG = "experimental-features = nix-command flakes";
}
