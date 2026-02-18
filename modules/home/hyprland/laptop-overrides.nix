# Hyprland laptop-specific overrides (ASUS Zenbook 14X OLED)
{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    # Auto-start hyprlock on boot
    exec-once = lib.mkAfter [
      "${pkgs.hyprlock}/bin/hyprlock"
    ];

    # Multi-monitor support for laptop (docked + undocked scenarios)
    #
    # UNDOCKED: Only built-in OLED display (2880x1800@120Hz, 1.5x scaling)
    # DOCKED: Desktop-matching 3-monitor setup (matches desktop configuration)
    #
    # DOCKED LAYOUT (same as desktop):
    # When docked via USB-C dock, monitors appear as DP-5, DP-6, DP-7
    # DP-5: Samsung S27F350 (1920x1080 portrait - left)
    # DP-6: Dell S3222DGM (2560x1440@120Hz - center, primary)
    # DP-7: AOC Q32G1WG4 (2560x1440@120Hz - right)
    # eDP-1: Laptop screen (disabled when docked/lid closed)
    monitor = lib.mkForce [
      # Built-in laptop display (primary, always configured first for undocked boot)
      "eDP-1,2880x1800@120,auto,1.5"

      # Docked setup (via USB-C dock - matches desktop layout)
      # These monitors are optional and only active when docked
      "DP-5,1920x1080@60,0x0,1,transform,3" # Left: Samsung portrait (270° rotation)
      "DP-6,2560x1440@60,1080x0,1" # Center: Dell 1440p 60Hz (primary when docked)
      "DP-7,2560x1440@60,3640x0,1" # Right: AOC 1440p 60Hz

      # Fallback: Disable unknown monitors
      ",disable"
    ];

    # Workspace assignments
    # DOCKED: Workspaces distributed across external monitors (DP-5, DP-6, DP-7 via dock)
    # UNDOCKED: All workspaces 1-9 available on built-in eDP-1 display
    workspace = [
      # Docked: External monitors (via USB-C dock)
      "1, monitor:DP-5, default:true" # Workspaces 1-3 → Left portrait monitor (Samsung)
      "2, monitor:DP-5"
      "3, monitor:DP-5"
      "4, monitor:DP-6, default:true" # Workspaces 4-6 → Main Dell monitor
      "5, monitor:DP-6"
      "6, monitor:DP-6"
      "7, monitor:DP-7, default:true" # Workspaces 7-9 → AOC monitor
      "8, monitor:DP-7"
      "9, monitor:DP-7"

      # Undocked: Built-in laptop display gets all workspaces
      "1, monitor:eDP-1, default:true"
      "2, monitor:eDP-1"
      "3, monitor:eDP-1"
      "4, monitor:eDP-1"
      "5, monitor:eDP-1"
      "6, monitor:eDP-1"
      "7, monitor:eDP-1"
      "8, monitor:eDP-1"
      "9, monitor:eDP-1"
    ];

    # Keep blur and shadows ENABLED (real GPU, not software rendering)
    # The laptop has Intel Iris Xe which handles blur/shadows efficiently
    decoration = {
      blur = {
        enabled = lib.mkDefault true;
      };
      shadow = {
        enabled = lib.mkDefault true;
      };
    };

    # Keep full animations enabled (no performance issues on real hardware)
    animations = {
      enabled = lib.mkDefault true;
    };

    # Brightness key bindings for laptop
    bind = [
      ", XF86MonBrightnessUp, exec, ${pkgs.swayosd}/bin/swayosd-client --brightness raise"
      ", XF86MonBrightnessDown, exec, ${pkgs.swayosd}/bin/swayosd-client --brightness lower"
      # Application shortcuts (matching desktop)
      "SUPER, B, exec, zen-beta"
      "SUPER SHIFT, D, exec, ${pkgs.discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland"
    ];

    # Lid switch bindings (disable display when closed, re-enable when opened)
    # When lid closes: disable built-in display + turn off keyboard backlight
    # When lid opens: re-enable built-in display + restore keyboard backlight
    bindl = [
      ",switch:on:Lid Switch, exec, ${pkgs.hyprland}/bin/hyprctl keyword monitor 'eDP-1, disable' && ${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 0"
      ",switch:off:Lid Switch, exec, ${pkgs.hyprland}/bin/hyprctl keyword monitor 'eDP-1, 2880x1800@120, 0x0, 1.5' && ${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 100%"
    ];

    # NO environment variable overrides needed
    # (no WLR_NO_HARDWARE_CURSORS, no software rendering)
    # The base Hyprland config already has touchpad natural_scroll = true
  };
}
