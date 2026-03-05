# Desktop-specific home configuration
{ lib, pkgs, ... }:
{
  imports = [
    ./default.nix
    ./hyprland/desktop-overrides.nix
  ];

  # Enable hyprlock for desktop (disabled globally due to VMware issues)
  programs.hyprlock.enable = lib.mkForce true;

  # Use hyprlock instead of swaylock-effects (swaylock-effects leaks CPU/RAM
  # over time due to continuous full-screen redraws when clock = true)
  services.hypridle.settings.general = lib.mkForce {
    lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    before_sleep_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
  };

  # Disable automatic suspend on idle for desktop
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
    # Suspend listener removed - desktop should never auto-suspend
  ];
}
