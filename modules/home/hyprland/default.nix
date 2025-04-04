{ inputs, ... }:
{
  imports = [
    ./hyprland.nix
    ./config.nix
    ./hyprlock.nix
    ./variables.nix
    ./hyprpaper.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
