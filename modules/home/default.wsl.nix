{
  inputs,
  lib,
  ...
}:
{
  # WSL-specific home-manager configuration
  # This configuration is CLI-focused for DevOps and development work
  # No desktop environment (Hyprland, Waybar, etc.)

  imports = [
    # Core CLI tools
    ./bat.nix # better cat command
    ./btop.nix # resources monitor
    ./fastfetch.nix # fetch tool
    ./fonts-wsl.nix # essential fonts for terminal (includes Nerd Font symbols)
    ./fzf.nix # fuzzy finder
    ./git.nix # version control
    ./gpg.nix # GPG configuration for commit signing
    ./lazygit.nix # terminal git client
    ./openssh.nix # ssh client
    ./micro.nix # nano replacement
    ./nvim.nix # neovim editor
    ./oh-my-posh/oh-my-posh.nix # zsh prompt theme
    ./packages.nix # additional packages (includes reposync)
    ./scripts/scripts.nix # personal scripts
    ./starship.nix # shell prompt
    ./tmux # terminal multiplexer
    ./vivid.nix # Rose Pine LS_COLORS for directory listings
    ./yazi.nix # terminal file manager
    ./zsh # shell

    # Development tools (includes kubectl, terraform, helm, etc.)
    ./development

    # VSCode Remote-WSL extension management
    # Generates extensions.json and helper scripts for Windows VSCode
    ./vscode-remote.nix
  ];

  # NOTE: GNOME Keyring is intentionally NOT enabled here.
  # It requires graphical-session-pre.target which never activates in WSL.
  # SSH agent: handled by gpg-agent with enableSSHSupport (see wsl-overrides.nix)
  #   - NixOS gnupg module sets SSH_AUTH_SOCK via environment.extraInit
  #   - SSH key passphrases prompted via pinentry-curses
  # Git credentials: use gh CLI instead of libsecret (which requires D-Bus secrets service)

  # Override git credential helper for WSL
  # Desktop uses git-credential-libsecret (requires org.freedesktop.secrets D-Bus service
  # from GNOME Keyring). In WSL, that service is dead, so use GitHub CLI instead.
  programs.git.settings.credential.helper = lib.mkForce "!/usr/bin/env gh auth git-credential";

  # WSL-specific packages that don't require their own module
  home.packages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
    # CLI improvements
    eza # Modern replacement for ls (required by ll alias)

    # Common WSL utilities
    wget
    curl
    htop
    iftop
    iotop
    tree
    unzip
    zip
    file
    which

    # Network tools
    netcat
    nmap
    tcpdump
    traceroute
    bind # includes dig, nslookup

    # Text processing
    gnused
    gawk
    gnugrep

    # Container tools (useful in WSL)
    podman
    podman-compose
    docker-compose

    # Monitoring and observability
    # prometheus conflicts with go-migrate (both have 'migrate' binary)
    # grafana is typically run as a service, not needed in CLI

    # Additional cloud tools
    awscli2
  ];
}
