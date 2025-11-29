{
  ...
}:
{
  # VM-specific home-manager configuration
  # This configuration is used for VMs (QEMU, VMware, etc.)

  imports = [
    # Import all standard home modules (same as default.nix)
    ./aseprite/aseprite.nix
    ./audacious.nix
    ./bat.nix
    ./browser.nix
    ./btop.nix
    ./cava.nix
    ./discord/discord.nix
    ./fastfetch.nix
    ./fzf.nix
    # ./gaming.nix # Optional: disable gaming packages in VM to save space
    ./ghostty.nix
    ./git.nix
    ./gnome.nix
    ./gtk.nix
    ./hyprland
    ./kitty.nix
    ./lazygit.nix
    ./openssh.nix
    ./micro.nix
    ./nemo.nix
    ./nvim.nix
    ./obsidian.nix
    ./p10k/p10k.nix
    ./packages.nix
    # ./retroarch.nix # Optional: disable in VM
    ./rofi.nix
    ./scripts/scripts.nix
    ./spicetify.nix
    ./starship.nix
    ./swaylock.nix
    ./swayosd.nix
    ./swaync/swaync.nix
    ./tmux
    ./vscode.nix
    ./waybar
    ./waypaper.nix
    ./xdg-mimes.nix
    ./yazi.nix
    ./zsh

    # Development tools
    ./development

    # VM-specific Hyprland overrides (must come after ./hyprland import)
    ./hyprland/vm-overrides.nix
  ];
}
