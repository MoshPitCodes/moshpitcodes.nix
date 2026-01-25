{
  inputs,
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
    ./fzf.nix # fuzzy finder
    ./git.nix # version control
    ./lazygit.nix # terminal git client
    ./openssh.nix # ssh client
    ./micro.nix # nano replacement
    ./nvim.nix # neovim editor
    ./oh-my-posh/oh-my-posh.nix # zsh prompt theme
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

  # WSL-specific packages that don't require their own module
  home.packages =
    with inputs.nixpkgs.legacyPackages.x86_64-linux;
    [
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
