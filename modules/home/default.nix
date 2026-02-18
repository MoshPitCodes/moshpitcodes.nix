# Home Manager modules aggregator
{ username, host, ... }:
{
  imports = [
    # Core
    ./packages.nix
    ./git.nix
    ./starship.nix
    ./ghostty.nix
    ./tmux.nix
    ./browser.nix
    ./media.nix
    ./btop.nix
    ./fastfetch.nix
    ./theming.nix
    ./language-servers.nix

    # Hyprland & desktop
    ./swayosd.nix
    ./swaylock.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./waypaper.nix
    ./swaync.nix
    ./rofi.nix
    ./zsh
    ./hyprland
    ./waybar

    # Shell & CLI tools
    ./bat.nix
    ./fzf.nix
    ./lazygit.nix
    ./nvim.nix
    ./sidecar.nix
    ./vivid.nix
    ./yazi.nix
    ./scripts

    # Security & system
    ./openssh.nix
    ./gpg.nix
    ./gnome.nix
    ./xdg-mimes.nix

    # Desktop applications
    ./obsidian.nix
    ./vscode.nix
    ./discord
    ./micro.nix
    ./viewnior.nix
    ./rider.nix

    # Media & entertainment
    ./audacious.nix
    ./cava.nix
    ./spicetify.nix
    ./gaming.nix

    # Development
    ./development
    ./backup-repos.nix
  ];

  # Basic home configuration
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # User-level nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
