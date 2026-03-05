# Laptop-specific home configuration
{ lib, ... }:
{
  imports = [
    ./default.nix
    ./hyprland/laptop-overrides.nix
  ];

  # Enable hyprlock for laptop
  programs.hyprlock.enable = lib.mkForce true;
}
