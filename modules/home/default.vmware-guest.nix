# VMware guest-specific home configuration
{ lib, pkgs, ... }:
{
  imports = [
    ./default.nix
    ./hyprland/vm-overrides.nix
  ];

  # Enable hyprlock for VMware guests
  programs.hyprlock.enable = lib.mkForce true;

  # Disable automatic suspend on idle for VMware guests
  # Keep screen dim, lock, and DPMS off, but remove suspend timeout
  services.hypridle.settings.listener = lib.mkForce [
    {
      timeout = 480;
      on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
      on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
    }
    {
      timeout = 600;
      on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
    }
    {
      timeout = 660;
      on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
      on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
    }
    # Suspend listener removed - VMware guests should never auto-suspend
  ];
}
