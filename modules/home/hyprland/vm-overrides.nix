{ lib, ... }:
{
  # Hyprland VM-specific overrides
  # This module overrides settings for VM environments (VMware, QEMU, etc.)

  # Override session variables for VM compatibility
  home.sessionVariables = {
    # Use VMware graphics driver instead of Intel
    LIBVA_DRIVER_NAME = lib.mkForce "vmwgfx";

    # Keep Vulkan backend but allow software rendering fallback
    # These are already set in the main variables.nix but we ensure they're correct for VMs
    WLR_NO_HARDWARE_CURSORS = lib.mkForce "1";
    WLR_RENDERER_ALLOW_SOFTWARE = lib.mkForce "1";

  };

  # Override Hyprland configuration for VM
  wayland.windowManager.hyprland.settings = {
    # Auto-detect monitors instead of hardcoding
    monitor = lib.mkForce [
      ",preferred,auto,1"  # Auto-configure any connected monitor
    ];

    # Disable some effects for better VM performance
    decoration = {
      blur = {
        enabled = lib.mkForce false;  # Disable blur for better performance
      };
      drop_shadow = lib.mkForce false;  # Disable shadows for better performance
    };

    # Reduce animations for better VM performance
    animation = lib.mkForce [
      "windows,1,3,default"
      "border,1,5,default"
      "fade,1,5,default"
      "workspaces,1,3,default"
    ];

    misc = {
      # Disable VFR for more consistent performance in VMs
      vfr = lib.mkForce false;

      # Force software cursors (important for VMs)
      no_hardware_cursors = lib.mkForce true;
    };
  };

  # Override extraConfig to remove hardcoded monitor settings
  wayland.windowManager.hyprland.extraConfig = lib.mkForce ''
    # VM-friendly monitor configuration
    monitor=,preferred,auto,1

    xwayland {
      force_zero_scaling = true
    }

    # Exec-once commands (keep your original startup apps if needed)
    exec-once = waybar & hyprpaper
  '';
}
