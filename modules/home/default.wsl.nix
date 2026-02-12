{
  inputs,
  pkgs,
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

    # GNOME Keyring for secrets + SSH agent (same approach as desktop)
    # Desktop uses services.gnome-keyring via graphical-session-pre.target;
    # WSL uses a custom systemd user service bound to default.target instead.
    ./keyring-wsl.nix
  ];

  # SSH_ASKPASS: When SSH needs a passphrase but has no TTY (e.g. in background
  # processes, IDE terminals, or AI coding tools), it falls back to SSH_ASKPASS.
  # We use seahorse on both desktop and WSL for a consistent experience.
  # WSLg provides X11/Wayland forwarding so the GTK dialog works natively.
  # SSH_ASKPASS_REQUIRE=prefer tells OpenSSH to always try askpass first, even
  # when a TTY is available - this ensures the graphical prompt is used consistently.
  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  # Git credential helper: use libsecret (same as desktop)
  # GNOME Keyring provides the org.freedesktop.secrets D-Bus service
  # via keyring-wsl.nix, so git-credential-libsecret works identically.

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
