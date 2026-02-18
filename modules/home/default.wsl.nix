# WSL home configuration (no Hyprland, no Waybar, no Wayland tools)
{ username, ... }:
{
  imports = [
    ./packages.nix
    ./git.nix
    ./starship.nix
    ./tmux.nix
    ./btop.nix
    ./fastfetch.nix
    ./zsh

    # Shell & CLI tools
    ./bat.nix
    ./fzf.nix
    ./lazygit.nix
    ./vivid.nix
    ./yazi.nix

    # Security
    ./openssh.nix
    ./gpg.nix
    ./gnome.nix
    ./xdg-mimes.nix

    # Development
    ./development
    ./backup-repos.nix

    # WSL-specific
    ./fonts-wsl.nix
    ./keyring-wsl.nix
    ./vscode-remote.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
