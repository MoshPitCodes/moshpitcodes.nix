# Hyprland VM-specific overrides
# Software rendering makes blur/shadows expensive - disable them
# Uses lib.mkForce to override base Hyprland settings
{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    # Auto-start hyprlock on boot
    exec-once = lib.mkAfter [
      "${pkgs.hyprlock}/bin/hyprlock"
    ];

    # Force single monitor for VMware (disable phantom second screen)
    # Order matters: specific rules first, catch-all last
    monitor = lib.mkForce [
      "Virtual-1,2560x1440@60,0x0,1" # Primary VMware monitor at explicit position
      "Unknown-1,disable" # Disable unknown monitors
      ",disable" # Catch-all: disable any other monitors
    ];

    # Disable hardware cursors (required for VM compatibility)
    env = [
      "WLR_NO_HARDWARE_CURSORS,1"
      "WLR_RENDERER_ALLOW_SOFTWARE,1"
      "LIBVA_DRIVER_NAME,vmwgfx"
    ];

    # Disable blur and shadows (heavy with software rendering)
    decoration = {
      blur = {
        enabled = lib.mkForce false;
      };
      shadow = {
        enabled = lib.mkForce false;
      };
    };

    # Snappy animations (fast enough to feel responsive, not disabled entirely)
    animations = {
      enabled = lib.mkForce true;
      bezier = lib.mkForce [
        "quick, 0.15, 0, 0.1, 1"
      ];
      animation = lib.mkForce [
        "global, 1, 2, quick"
        "workspaces, 1, 1.5, quick, slide"
      ];
    };

    # VM performance misc settings
    misc = {
      vfr = true;
      disable_autoreload = true; # Don't reload config on monitor changes
    };
  };
}
