# Laptop-specific home configuration
{ lib, pkgs, ... }:
{
  imports = [
    ./default.nix
    ./hyprland/laptop-overrides.nix
  ];

  # Enable hyprlock for laptop
  programs.hyprlock.enable = lib.mkForce true;

  # Use hyprlock instead of swaylock-effects (swaylock-effects leaks CPU/RAM
  # over time due to continuous full-screen redraws when clock = true)
  services.hypridle.settings.general = lib.mkForce {
    lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    before_sleep_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
  };
}
