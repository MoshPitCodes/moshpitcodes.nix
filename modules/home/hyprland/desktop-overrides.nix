# Hyprland desktop-specific overrides (i7-13700K, RTX 4070Ti Super)
{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    # Auto-start applications (Discord top, btop bottom)
    exec-once = lib.mkAfter [
      "${pkgs.hyprlock}/bin/hyprlock"
      "sleep 2 && ${pkgs.discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland"
      "${pkgs.bash}/bin/bash -lc 'for i in {1..60}; do ${pkgs.hyprland}/bin/hyprctl clients | ${pkgs.gnugrep}/bin/grep -qi \"class: discord\" && break; sleep 1; done; ${pkgs.ghostty}/bin/ghostty --title=btop-monitor -e ${pkgs.btop}/bin/btop'"
    ];
    # Desktop monitor configuration (3-monitor setup)
    # HDMI-A-1: Samsung S27F350 (1920x1080 portrait - left)
    # DP-1: Dell S3222DGM (2560x1440@120Hz - center, primary)
    # DP-2: AOC Q32G1WG4 (2560x1440@120Hz - right)
    monitor = lib.mkForce [
      "HDMI-A-1,1920x1080@60,0x0,1,transform,3" # Left: Samsung portrait (270° rotation)
      "DP-1,2560x1440@120,1080x0,1" # Center: Dell 1440p 120Hz (primary)
      "DP-2,2560x1440@120,3640x0,1" # Right: AOC 1440p 120Hz
    ];

    # Workspace assignments per monitor (3 workspaces each)
    workspace = [
      "1, monitor:HDMI-A-1, default:true" # Workspaces 1-3 → Left portrait monitor
      "2, monitor:HDMI-A-1"
      "3, monitor:HDMI-A-1"
      "4, monitor:DP-1, default:true" # Workspaces 4-6 → Main Dell monitor
      "5, monitor:DP-1"
      "6, monitor:DP-1"
      "7, monitor:DP-2, default:true" # Workspaces 7-9 → AOC monitor
      "8, monitor:DP-2"
      "9, monitor:DP-2"
    ];

    # Custom keybindings
    bind = [
      "SUPER, B, exec, zen-beta" # Open Zen browser (workspace 7 via window rule)
      "SUPER SHIFT, D, exec, ${pkgs.discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland" # Open Discord (workspace 1 via window rule)
    ];

    # Window focus behavior - prevents ALL windows from stealing focus
    misc = {
      focus_on_activate = lib.mkForce false;
    };

    # Desktop has full Nvidia GPU - keep all effects enabled
    decoration = {
      blur.enabled = lib.mkDefault true;
      shadow.enabled = lib.mkDefault true;
    };

    animations.enabled = lib.mkDefault true;

    # Nvidia-specific environment variables for Wayland/Hyprland
    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "XCURSOR_SIZE,24"
    ];

    # Optional: Uncomment if experiencing cursor issues with Nvidia
    # env = lib.mkAfter [ "WLR_NO_HARDWARE_CURSORS,1" ];
  };
}
